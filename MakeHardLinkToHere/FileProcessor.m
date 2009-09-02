#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor


- (void) displayErrorLog:(NSString *)aText
{
	[[NSApp delegate] 
		performSelectorOnMainThread:@selector(displayErrorLog:) 
		withObject:aText waitUntilDone:NO];
}

- (void) startTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	NSFileManager* file_manager = [NSFileManager defaultManager];
	while (source = [enumerator nextObject]) {
		NSString *newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		NSString *destination = [location stringByAppendingPathComponent:newname];
		if (![file_manager linkPath:source toPath:destination handler:self] ){
			[self displayErrorLog:
			 [NSString stringWithFormat:@"Fail to make hard link from %@ to %@\n", source, destination]];
		}
	}
	[pool release];
}
@end
