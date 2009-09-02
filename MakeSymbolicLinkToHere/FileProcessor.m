#import "FileProcessor.h"
#import "PathExtra.h"
#include <unistd.h>

@implementation FileProcessor

- (void) startTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	while (source = [enumerator nextObject]) {
		NSString *newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		NSString *relpath = [source relativePathWithBase:location];
		if (symlink([relpath fileSystemRepresentation], 
					[[location stringByAppendingPathComponent:newname] fileSystemRepresentation]) != 0) {
			NSLog(@"Error to make symbolic link : %d", errno);
		}
	}
	[pool release];
}
@end
