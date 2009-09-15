#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	if ([currentSource isFolder]) {
		[self displayErrorLog:
		 NSLocalizedStringFromTable(@"Can't make a hard link for a folder", @"PaticularLocalizable", @"")];
		return;
	}
	NSString *newname = [[currentSource lastPathComponent] uniqueNameAtLocation:currentLocation];
	NSString *destination = [currentLocation stringByAppendingPathComponent:newname];
	if (![[NSFileManager defaultManager] linkPath:currentSource toPath:destination handler:self] ){
		[self displayErrorLog:
			 NSLocalizedStringFromTable(@"Failed to make hard link from %@ to %@.", @"ParticularLocalizable", @""),
						currentSource, destination];
	}
}

@end
