#import "FileProcessor.h"
#import "PathExtra.h"
#include <unistd.h>
#include <string.h>

#define useLog 0

@implementation FileProcessor

- (void)doTask:(id)sender
{
	NSString *newname = [[currentSource lastPathComponent] uniqueNameAtLocation:currentLocation];
	NSString *destination = [currentLocation stringByAppendingPathComponent:newname];
	NSString *relpath = [currentSource relativePathWithBase:destination];
#if useLog		
	NSLog(@"relative path: %@", relpath);
	NSLog(@"destination : %@", destination);
#endif		
	if (symlink([relpath fileSystemRepresentation], 
				[destination fileSystemRepresentation]) != 0) {
		char *msg = strerror(errno);
		[self displayErrorLog:
			   NSLocalizedStringFromTable(@"Failed to make symbolic link with error : %d.", @"PaticularLocalizable", @""),
			   [NSString stringWithUTF8String:msg]];
	}
}
@end
