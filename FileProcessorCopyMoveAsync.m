#import "FileProcessorCopyMoveAsync.h"
#import "PathExtra/PathExtra.h"
#import "ProgressWindowController.h"
#import "AppController.h"

#define useLog 0

@implementation FileProcessorCopyMoveAsync

- (id)init
{
	if (self = [super init]) {
		char *login_shell = getenv("SHELL");
		self.loginShell = [NSString stringWithUTF8String:login_shell];
	}
	return self;
}

static void statusCallback (FSFileOperationRef fileOp,
							const char *currentItem,
							FSFileOperationStage stage,
							OSStatus error,
							CFDictionaryRef statusDictionary,
							void *info)
{
#if useLog
	NSLog(@"Callback got called.");
#endif
	if (error == userCanceledErr) {
		return;
	}
	FileProcessorBase *processor = (__bridge FileProcessorBase *)(info);
	if (error != noErr) {
		[processor displayErrorLog:@"Failed to process %s with error %d", currentItem, error];
	}
	
	OSStatus err;
	if (stage == kFSOperationStageComplete) {
		err = FSFileOperationUnscheduleFromRunLoop(fileOp, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		if (err != noErr)
			[processor displayErrorLog:@"Failed to FSFileOperationUnscheduleFromRunLoop : %d", err];
		CFRelease(fileOp);
		[processor doTask:NULL];
	} else {
#if useLog		
		NSLog(@"is canceled %d", processor.isCanceled);
#endif
		if (processor.isCanceled) {
			err = FSFileOperationCancel(fileOp);
			if (err != noErr)
				[processor displayErrorLog:@"Fail to FSFileOperationCancel : %d", err];
			err = FSFileOperationUnscheduleFromRunLoop(fileOp, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
			if (err != noErr)
				[processor displayErrorLog:@"Failed to FSFileOperationUnscheduleFromRunLoop : %d", err];
			CFRelease(fileOp);
			CFRunLoopStop(CFRunLoopGetCurrent());
		}
	}
}

- (void)doTask:(id)sender
{
#if useLog
	NSLog(@"start doTask");
#endif
	NSString* source = [self.enumerator nextObject];
	if (!source || self.isCanceled) {
#if useLog
		NSLog(@"will stop run loop");
#endif
		CFRunLoopStop(CFRunLoopGetCurrent());
		return;
	}
	
	source = [source cleanPath];
	self.nuName = [source lastPathComponent];
	OSStatus status;

	NSString *status_msg = [NSString stringWithFormat:
							NSLocalizedStringFromTable(@"ProcessingFromTo", @"ParticularLocalizable", @""), 
							self.nuName, self.currentLocation];
	[self.owner performSelectorOnMainThread:@selector(setStatusMessage:) withObject: status_msg waitUntilDone:NO];
	
	
	if ([self resolveNewName:source]) {
#if useLog
        NSString *destination = [currentLocation stringByAppendingPathComponent:_nuName];
        NSLog(@"Copy source : %@", source);
        NSLog(@"Copy destination : %@", destination);
#endif			
        FSFileOperationRef fileOp = FSFileOperationCreate(NULL);
        const char *source_char = [source fileSystemRepresentation];
        const char *loc_char = [self.currentLocation fileSystemRepresentation];
        status = FSFileOperationScheduleWithRunLoop(fileOp, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        if (status != noErr) {
            [self displayErrorLog:@"Failed to FSFileOperationScheduleWithRunLoop with error : %d", status];
            CFRelease(fileOp);
            goto bail;
        }
        FSFileOperationClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        status = (*processPathAsync)(fileOp, source_char,loc_char, (__bridge CFStringRef)self.nuName,
                                       kFSFileOperationDefaultOptions|kFSFileOperationOverwrite, 
                                       statusCallback,2,&context);
        if (status != noErr) {
            [self displayErrorLog:@"Failed to FSPathCopy/MoveObjectAsync with error: %d", status];
            CFRelease(fileOp);
            goto bail;
        }
        NSString *loc_name = [self.currentLocation lastPathComponent];
        NSString *source_name = [source lastPathComponent];
        if (![source_name isEqualToString:self.nuName]) {
            loc_name = [loc_name stringByAppendingPathComponent:self.nuName];
            status_msg = [NSString stringWithFormat:
                                    NSLocalizedStringFromTable(@"ProcessingFromTo", 
                                                               @"ParticularLocalizable", @""), 
                                    source_name, loc_name];
            [self.owner performSelectorOnMainThread:@selector(setStatusMessage:) withObject: status_msg waitUntilDone:NO];
        }
    }
    
    [self.appController performSelectorOnMainThread:@selector(updateOnFinder:)
                            withObject:[self.currentLocation stringByAppendingPathComponent:self.nuName]
                                    waitUntilDone:NO];
	
bail:
	return;
}

- (void)startThreadTask:(ProgressWindowController *)sender
{
	@autoreleasepool {
        for (NSString *path in self.locations) {
            self.currentLocation = path;
            BOOL done = NO;
            self.enumerator = [self.sourceItems objectEnumerator];
            [self doTask:sender];
            do
            {
                SInt32    result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 3, YES);
                if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)) {
    #if useLog
                    NSLog(@"run loop is stoped");
    #endif
                    done = YES;
                }
            }
            while (!done);
            if (self.isCanceled) break;
        }
        [sender performSelectorOnMainThread:@selector(taskEnded:) withObject:self waitUntilDone:NO];
    }
	[NSThread exit];
}

@end
