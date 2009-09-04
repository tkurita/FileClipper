#import "FileProcessor.h"
#import "PathExtra.h"
#include <unistd.h>

@implementation FileProcessor

- (void)doTask:(id)sender
{
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	while (source = [enumerator nextObject]) {
		NSString *newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		NSString *relpath = [source relativePathWithBase:location];
		if (symlink([relpath fileSystemRepresentation], 
					[[location stringByAppendingPathComponent:newname] fileSystemRepresentation]) != 0) {
			[self displayErrorLog:[NSString stringWithFormat:@"Error to make symbolic link : %d\n", errno]];
		}
	}
}
@end
