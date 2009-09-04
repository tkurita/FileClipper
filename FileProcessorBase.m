#import "FileProcessorBase.h"
#import "PathExtra.h"

@implementation FileProcessorBase
@synthesize location, sourceItems, owner, currentSource, newName;

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

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	NSLog([errorInfo description]);
	return NO;
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
	[owner performSelectorOnMainThread:@selector(askNewName:) withObject:self waitUntilDone:YES];
	[lock lock];
	[lock unlock];
	return (newName && ![newName isEqualToString:[source lastPathComponent]]);
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
