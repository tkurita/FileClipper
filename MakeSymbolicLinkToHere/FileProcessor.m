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
			[self displayErrorLog:[NSString stringWithFormat:
								   NSLocalizedString(@"Fail to make symbolic link with error : %d\n", @""), errno]];
		}
	}
}
@end
