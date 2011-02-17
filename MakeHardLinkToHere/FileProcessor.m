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
	//NSString *newname = [[currentSource lastPathComponent] uniqueNameAtLocation:currentLocation];
	if (![self resolveNewName:currentSource]) {
		return;
	}	
	NSString *destination = [currentLocation stringByAppendingPathComponent:self.newName];
	
	NSFileManager *file_manager = [NSFileManager defaultManager];
	NSNumber *source_device = [[file_manager fileAttributesAtPath:currentSource traverseLink:NO]
							   objectForKey:NSFileSystemNumber];
	NSNumber *location_device = [[file_manager fileAttributesAtPath:currentLocation traverseLink:NO]
								 objectForKey:NSFileSystemNumber];
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
	
	if (![source_device isEqualToNumber:location_device]) {
		[self displayErrorLog:
		 NSLocalizedStringFromTable(@"Can't make a hard link between different devices.", @"ParticularLocalizable", @"")];
		return;
	}
	
	if (![file_manager linkPath:currentSource toPath:destination handler:self] ){
		[self displayErrorLog:
			 NSLocalizedStringFromTable(@"Failed to make hard link from %@ to %@.", @"ParticularLocalizable", @""),
						currentSource, destination];
	}
}

@end
