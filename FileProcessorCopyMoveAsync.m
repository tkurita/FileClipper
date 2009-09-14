#import "FileProcessorCopyMoveAsync.h"
#import "PathExtra.h"
#import "ProgressWindowController.h"

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
	FileProcessor *processor = info;
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
	NSString* source = [enumerator nextObject];
	if (!source || isCanceled) {
#if useLog
		NSLog(@"will stop run loop");
#endif
		CFRunLoopStop(CFRunLoopGetCurrent());
		return;
	}
	
	source = [source cleanPath];
	self.newName = [source lastPathComponent];
	OSStatus status;
	if ([self resolveNewName:source]) {
		if (![self trySVN:@"cp" withSource:source]) {
			//if (YES) {
#if useLog
			NSString *destination = [currentLocation stringByAppendingPathComponent:newName];
			NSLog(@"Copy source : %@", source);
			NSLog(@"Copy destination : %@", destination);
#endif			
			FSFileOperationRef fileOp = FSFileOperationCreate(NULL);
			const char *source_char = [source fileSystemRepresentation];
			const char *loc_char = [currentLocation fileSystemRepresentation];
			status = FSFileOperationScheduleWithRunLoop(fileOp, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
			if (status != noErr) {
				[self displayErrorLog:@"Failed to FSFileOperationScheduleWithRunLoop with error : %d", status];
				CFRelease(fileOp);
				goto bail;
			}
			FSFileOperationClientContext context = {0, self, NULL, NULL, NULL};
			status = (*processPathAsync)(fileOp, source_char,loc_char, (CFStringRef)newName,
										   kFSFileOperationDefaultOptions|kFSFileOperationOverwrite, 
										   statusCallback,2,&context);
			if (status != noErr) {
				[self displayErrorLog:@"Failed to FSPathCopyObjectAsync with error: %d", status];
				CFRelease(fileOp);
				goto bail;
			}
			NSString *loc_name = [currentLocation lastPathComponent];
			NSString *source_name = [source lastPathComponent];
			if (![source_name isEqualToString:newName]) 
				loc_name = [loc_name stringByAppendingPathComponent:newName];
			NSString *status_msg = [NSString stringWithFormat:
									NSLocalizedStringFromTable(@"ProcessingFromTo", @"PaticularLocalizabel.strings", @""), 
									source_name, loc_name];
			[owner performSelectorOnMainThread:@selector(setStatusMessage:) withObject: status_msg waitUntilDone:NO];
		}
	}
	
bail:
	return;
}

- (void)startThreadTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	for (NSString *path in locations) {
		self.currentLocation = path;
		BOOL done = NO;
		self.enumerator = [sourceItems objectEnumerator];
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
		if (isCanceled) break;
	}
	[pool release];
	[sender performSelectorOnMainThread:@selector(taskEnded:) withObject:self waitUntilDone:NO];
	[NSThread exit];
}

@end
