#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	if ([currentSource isFolder]) {
		[self displayErrorLog:
		 NSLocalizedStringFromTable(@"Can't make a hard link for a folder", @"ParticularLocalizable", @"")];
		return;
	}
	NSString *newname = [[currentSource lastPathComponent] uniqueNameAtLocation:currentLocation];
	NSString *destination = [currentLocation stringByAppendingPathComponent:newname];
	NSFileManager *file_manager = [NSFileManager defaultManager];
	if (![file_manager linkPath:currentSource toPath:destination handler:self] ){
		[self displayErrorLog:
			 NSLocalizedStringFromTable(@"Failed to make hard link from %@ to %@.", @"ParticularLocalizable", @""),
						currentSource, destination];
		NSNumber *source_device = [[file_manager fileAttributesAtPath:currentSource traverseLink:NO]
									objectForKey:NSFileDeviceIdentifier];
		NSNumber *location_device = [[file_manager fileAttributesAtPath:currentLocation traverseLink:NO]
									 objectForKey:NSFileDeviceIdentifier];
		if (![source_device isEqualToNumber:location_device]) {
			[self displayErrorLog:
			 NSLocalizedStringFromTable(@"Can't make a hard link between different devices.", @"ParticularLocalizable", @"")];
		}
	}
}

@end
