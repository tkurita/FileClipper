#import "FileProcessorBase.h"
#import "PathExtra.h"

#define useLog 0

@implementation FileProcessorBase
@synthesize locations, currentLocation, sourceItems, owner, currentSource, newName, loginShell, enumerator, isCanceled;

- (id)init
{
	if (self = [super init]) {
		lock = [NSLock new];
		isCanceled = NO;
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
	[task setLaunchPath:loginShell];
	[task setArguments:arguments];
	[task setStandardError:[NSPipe pipe]];
	[task setStandardOutput:[NSPipe pipe]];
	return [task autorelease];
}

- (BOOL)trySVN:(NSString *)command withSource:(NSString *)source
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSTask* svntask = [self loginShellTask:[NSArray arrayWithObjects:@"-lc", @"svn info \"$0\"",source, nil]];
	BOOL result = NO;
	[svntask launch];
	[svntask waitUntilExit];
	if ([svntask terminationStatus] != 0) {
		goto bail;
	}
	
	svntask = [self loginShellTask:[NSArray arrayWithObjects:@"-lc", @"svn info \"$0\"", currentLocation, nil]];
	[svntask launch];
	[svntask waitUntilExit];
	
	if ([svntask terminationStatus] != 0) {
		goto bail;
	}
	
	NSString *svncommand = [NSString stringWithFormat:@"svn %@ \"$0\" \"$1\"", command];
	svntask = [self loginShellTask:[NSArray arrayWithObjects:@"-lc", svncommand, source, 
									[currentLocation stringByAppendingPathComponent:newName], nil]];
	[svntask launch];
	[svntask waitUntilExit];
	if ([svntask terminationStatus] != 0) {
		NSLog([[[NSString alloc] initWithData:[[[svntask standardError] fileHandleForReading] availableData]
									 encoding:NSUTF8StringEncoding] autorelease]);
		goto bail;
	}
	
	result = YES;
bail:
	[pool release];
	return result;
}

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	NSLog(@"error in file manager");
	NSLog([errorInfo description]);
	return YES;
}

- (void) displayErrorLog:(NSString *)aText
{
	[[NSApp delegate] 
		performSelectorOnMainThread:@selector(displayErrorLog:) 
		withObject:aText waitUntilDone:NO];
}

- (void)lock
{
	[lock lock];
}

- (void)unlock
{
	[lock unlock];
}

- (BOOL)resolveNewName:(NSString *)source
{
	self.currentSource = source;
	self.newName = nil;
	if ([[currentLocation stringByAppendingPathComponent:[source lastPathComponent]] fileExists]) {
		[owner performSelectorOnMainThread:@selector(askNewName:) withObject:self waitUntilDone:YES];
		[lock lock];
		[lock unlock];
	} else {
		self.newName = [source lastPathComponent];
	}
	return (newName != nil);
}

- (void)doTask:(id)sender
{
	
}

- (void)startThreadTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	for (NSString *path in locations) {
		self.currentLocation = path;
		for (NSString *source in sourceItems) {
			self.currentSource = source;
			[self doTask:sender];
		}
	}
	[pool release];
	[sender performSelectorOnMainThread:@selector(taskEnded:) withObject:self waitUntilDone:NO];
	[NSThread exit];
}

- (void) dealloc
{
	[sourceItems release];
	[locations release];
	[currentLocation release];
	[newName release];
	[lock release];
	[enumerator release];
	[super dealloc];
}
@end
