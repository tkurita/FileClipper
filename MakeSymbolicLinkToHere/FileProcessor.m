#import "FileProcessor.h"
#import "PathExtra.h"
#include <unistd.h>
#include <string.h>

#define useLog 0

@implementation FileProcessor

- (void)doTask:(id)sender
{
	if (![self resolveNewName:self.currentSource]) {
		return;
	}	
	NSString *destination = [self.currentLocation stringByAppendingPathComponent:self.nuName];
	NSString *relpath = [self.currentSource relativePathWithBase:destination];
#if useLog		
	NSLog(@"relative path: %@", relpath);
	NSLog(@"destination : %@", destination);
#endif
	if ([destination fileExists]) {
		NSInteger tag;
		if (![[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation 
													source:self.currentLocation destination:@""
														   files:[NSArray arrayWithObject:self.nuName] tag:&tag]) {
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
