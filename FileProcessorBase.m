#import "FileProcessorBase.h"

@implementation FileProcessorBase
@synthesize location, sourceItems, owner;

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path owner:(id)ownerObject
{
	self = [self init];
	[self setLocation:path];
	[self setSourceItems:array];
	self.owner = ownerObject;
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

- (void) startTask:(id)sender
{

}
@end
