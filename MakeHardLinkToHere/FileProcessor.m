#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	NSString *newname = [[currentSource lastPathComponent] uniqueNameAtLocation:currentLocation];
	NSString *destination = [currentLocation stringByAppendingPathComponent:newname];
	if (![[NSFileManager defaultManager] linkPath:currentSource toPath:destination handler:self] ){
		[self displayErrorLog:
			 NSLocalizedStringFromTable(@"Failed to make hard link from %@ to %@.", @"ParticularLocalizable", @""),
						currentSource, destination];
	}
}

@end
