#import "FileProcessorBase.h"
#import "PathExtra.h"

#define useLog 0

@implementation FileProcessorBase
@synthesize location, sourceItems, owner, currentSource, newName, loginShell;

- (id)init
{
	if (self = [super init]) {
		lock = [NSLock new];
	}
	return self;
}

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path owner:(id)ownerObject
{
	self = [self init];
	self.location = path;
	self.sourceItems = array;
	self.owner = ownerObject;
	return self;
}

- (void)setLocation:(NSString *)path
{
	path = [path cleanPath];
	[path retain];
	[location autorelease];
	location = path;
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
	NSTask* svntask = [self loginShellTask:[NSArray arrayWithObjects:@"-lc", @"svn info \"$0\"",source, nil]];
	BOOL result = NO;
	[svntask launch];
	[svntask waitUntilExit];
	if ([svntask terminationStatus] != 0) {
		goto bail;
	}
	
	svntask = [self loginShellTask:[NSArray arrayWithObjects:@"-lc", @"svn info \"$0\"", location, nil]];
	[svntask launch];
	[svntask waitUntilExit];
	
	if ([svntask terminationStatus] != 0) {
		goto bail;
	}
	
	NSString *svncommand = [NSString stringWithFormat:@"svn %@ \"$0\" \"$1\"", command];
	svntask = [self loginShellTask:[NSArray arrayWithObjects:@"-lc", svncommand, source, 
									[location stringByAppendingPathComponent:newName], nil]];
	[svntask launch];
	[svntask waitUntilExit];
	if ([svntask terminationStatus] != 0) {
		NSLog([[[NSString alloc] initWithData:[[[svntask standardError] fileHandleForReading] availableData]
									 encoding:NSUTF8StringEncoding] autorelease]);
		goto bail;
	}
	
	result = YES;
bail:
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
	if ([[location stringByAppendingPathComponent:[source lastPathComponent]] fileExists]) {
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
	[self doTask:sender];
	[pool release];
	[sender performSelectorOnMainThread:@selector(taskEnded:) withObject:self waitUntilDone:NO];
	[NSThread exit];
}

- (void) dealloc
{
	[sourceItems release];
	[location release];
	[newName release];
	[lock release];
	[super dealloc];
}
@end
