#import "FileProcessorBase.h"
#import "PathExtra.h"

@implementation FileProcessorBase
@synthesize location, sourceItems, owner, currentSource, newName;

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path owner:(id)ownerObject
{
	self = [self init];
	self.location = [path cleanPath];
	self.sourceItems = array;
	self.owner = ownerObject;
	lock = [NSLock new];
	return self;
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

- (void)startTask:(id)sender
{

}

- (void) dealloc
{
	[sourceItems release];
	[location release];
	[lock release];
	[super dealloc];
}
@end
