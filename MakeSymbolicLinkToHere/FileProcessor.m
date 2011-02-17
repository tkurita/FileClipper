#import "FileProcessor.h"
#import "PathExtra.h"
#include <unistd.h>
#include <string.h>

#define useLog 0

@implementation FileProcessor

- (void)doTask:(id)sender
{
	//NSString *newname = [[currentSource lastPathComponent] uniqueNameAtLocation:currentLocation];
	if (![self resolveNewName:currentSource]) {
		return;
	}	
	NSString *destination = [currentLocation stringByAppendingPathComponent:self.newName];
	NSString *relpath = [currentSource relativePathWithBase:destination];
#if useLog		
	NSLog(@"relative path: %@", relpath);
	NSLog(@"destination : %@", destination);
#endif
	if ([destination fileExists]) {
		NSInteger tag;
		if (![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation 
													source:currentLocation destination:@"" 
														   files:[NSArray arrayWithObject:self.newName] tag:&tag]) {
			[self displayErrorLog:
					NSLocalizedString(@"Failed to replace : %@", @""), destination];
			return;
		}
	}
			
	if (symlink([relpath fileSystemRepresentation], 
				[destination fileSystemRepresentation]) != 0) {
		char *msg = strerror(errno);
		[self displayErrorLog:
			   NSLocalizedStringFromTable(@"Failed to make symbolic link with error : %d.", @"ParticularLocalizable", @""),
			   [NSString stringWithUTF8String:msg]];
	}
}
@end
