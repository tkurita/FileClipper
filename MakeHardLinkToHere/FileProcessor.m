#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	if ([self.currentSource isFolder]) {
		[self displayErrorLog:
		 NSLocalizedStringFromTable(@"Can't make a hard link for a folder", @"ParticularLocalizable", @"")];
		return;
	}

	if (![self resolveNewName:self.currentSource]) {
		return;
	}	
	NSString *destination = [self.currentLocation stringByAppendingPathComponent:self.nuName];
	
	NSFileManager *file_manager = [NSFileManager defaultManager];
	NSNumber *source_device = [[file_manager fileAttributesAtPath:self.currentSource traverseLink:NO]
							   objectForKey:NSFileSystemNumber];
	NSNumber *location_device = [[file_manager fileAttributesAtPath:self.currentLocation traverseLink:NO]
								 objectForKey:NSFileSystemNumber];
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
	
	if (![source_device isEqualToNumber:location_device]) {
		[self displayErrorLog:
		 NSLocalizedStringFromTable(@"Can't make a hard link between different devices.", @"ParticularLocalizable", @"")];
		return;
	}
	
	if (![file_manager linkPath:self.currentSource toPath:destination handler:self] ){
		[self displayErrorLog:
			 NSLocalizedStringFromTable(@"Failed to make hard link from %@ to %@.", @"ParticularLocalizable", @""),
						self.currentSource, destination];
	}
}

@end
