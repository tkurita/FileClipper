#import "FileProcessorBase.h"
#import "PathExtra.h"

#define useLog 0

@implementation FileProcessorBase

- (id)init
{
	if (self = [super init]) {
		self.lockobj = [NSLock new];
		self.isCanceled = NO;
	}
	return self;
}

- (id)initWithSourceItems:(NSArray *)array toLocations:(NSArray *)pathes owner:(id)ownerObject
{
	self = [self init];
	self.locations = pathes;
	self.sourceItems = array;
	self.owner = ownerObject;
	return self;
}

- (NSTask*)loginShellTask:(NSArray*)arguments
{
	NSTask* task = [NSTask new];
	[task setLaunchPath:_loginShell];
	[task setArguments:arguments];
	[task setStandardError:[NSPipe pipe]];
	[task setStandardOutput:[NSPipe pipe]];
	return task;
}

- (BOOL)trySVN:(NSString *)command withSource:(NSString *)source
{
	@autoreleasepool {
        NSTask* svntask = [self loginShellTask:@[@"-lc", @"svn info \"$0\"",source]];
        BOOL result = NO;
        [svntask launch];
        [svntask waitUntilExit];
        if ([svntask terminationStatus] != 0) {
            return result;
        }
        
        svntask = [self loginShellTask:@[@"-lc", @"svn info \"$0\"", _currentLocation]];
        [svntask launch];
        [svntask waitUntilExit];
        
        if ([svntask terminationStatus] != 0) {
            return result;
        }
        NSString *err_text = [[NSString alloc] initWithData:
                                    [[[svntask standardError] fileHandleForReading] availableData]
                                                    encoding:NSUTF8StringEncoding];
        if (0 != ([err_text rangeOfString:@"(Not a versioned resource)"].length)) {
            return result;
        }
        /*
        NSLog(@"stdout : %@", out_text);
        NSLog(@"stderr : %@", err_text);
        */
        NSString *svncommand = [NSString stringWithFormat:@"svn %@ \"$0\" \"$1\"", command];
        svntask = [self loginShellTask:@[@"-lc", svncommand, source, 
                                        [_currentLocation stringByAppendingPathComponent:_nuName]]];
        [svntask launch];
        [svntask waitUntilExit];
        if ([svntask terminationStatus] != 0) {
            NSLog(@"%@", [[NSString alloc] initWithData:[[[svntask standardError] fileHandleForReading] availableData]
                                         encoding:NSUTF8StringEncoding]);
        }
	}
	return YES;
}

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	NSLog(@"Error in file manager : %@", [errorInfo description]);
	return NO;
}

- (void)displayErrorLog:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
	NSString *msg = [[NSString alloc] initWithFormat:format arguments:argumentList];
	[[NSApp delegate] 
		 performSelectorOnMainThread:@selector(displayErrorLog:) 
		 withObject:msg waitUntilDone:NO];	
    va_end(argumentList);
}

- (void)lock
{
	[_lockobj lock];
}

- (void)unlock
{
	[_lockobj unlock];
}

- (BOOL)resolveNewName:(NSString *)source
{
	self.currentSource = source;
	self.nuName = nil;
	if ([[_currentLocation stringByAppendingPathComponent:[source lastPathComponent]] fileExists]) {
		[_owner performSelectorOnMainThread:@selector(askNewName:) withObject:self waitUntilDone:YES];
		[_lockobj lock];
		[_lockobj unlock];
	} else {
		self.nuName = [source lastPathComponent];
	}
	return (_nuName != nil);
}

- (void)doTask:(id)sender
{
	
}

- (void)startThreadTask:(id)sender
{
	@autoreleasepool {
        for (NSString *path in _locations) {
            self.currentLocation = path;
            for (NSString *source in _sourceItems) {
                self.currentSource = source;
                NSString *status_msg = [NSString stringWithFormat:
                                        NSLocalizedStringFromTable(@"ProcessingFromTo", 
                                                                   @"ParticularLocalizable", @""), 
                                        [source lastPathComponent], _currentLocation];
                [_owner performSelectorOnMainThread:@selector(setStatusMessage:)
                                        withObject: status_msg waitUntilDone:NO];
                [self doTask:sender];
            }
        }
    }
	[sender performSelectorOnMainThread:@selector(taskEnded:) withObject:self waitUntilDone:NO];
	[NSThread exit];
}

@end
