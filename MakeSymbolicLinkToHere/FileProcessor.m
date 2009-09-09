#import "FileProcessor.h"
#import "PathExtra.h"
#include <unistd.h>
#include <string.h>

#define useLog 0
@implementation FileProcessor

- (void)doTask:(id)sender
{
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	while (source = [enumerator nextObject]) {
		NSString *newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		NSString *destination = [location stringByAppendingPathComponent:newname];
		NSString *relpath = [source relativePathWithBase:destination];
#if useLog		
		NSLog(@"relative path: %@", relpath);
		NSLog(@"destination : %@", destination);
#endif		
		if (symlink([relpath fileSystemRepresentation], 
					[destination fileSystemRepresentation]) != 0) {
			char *msg = strerror(errno);
			[self displayErrorLog:[NSString stringWithFormat:
								   NSLocalizedString(@"Fail to make symbolic link because %@", @""), 
								   [NSString stringWithUTF8String:msg]]];
		}
	}
}
@end
