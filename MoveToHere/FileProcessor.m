#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (void) startTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	NSFileManager* file_manager = [NSFileManager defaultManager];
	while (source = [enumerator nextObject]) {
		if (![[source stringByDeletingLastPathComponent] isEqualToString:location]) {
			NSString* newname = [[source lastPathComponent] uniqueNameAtLocation:location];
			[file_manager movePath:source toPath:[location stringByAppendingPathComponent:newname] handler:self];
		}
	}
	[pool release];
}
@end
