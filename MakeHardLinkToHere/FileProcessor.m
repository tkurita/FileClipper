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
    NSError *error = nil;
    NSNumber *source_device = [[file_manager attributesOfItemAtPath:self.currentSource
                                                              error:&error]
                                                    objectForKey:NSFileSystemNumber];
    if (error) {
        [NSApp presentError:error];
        return;
    }

    NSNumber *location_device = [[file_manager attributesOfItemAtPath:self.currentLocation
                                                                error:&error]
                                 objectForKey:NSFileSystemNumber];
    if (error) {
        [NSApp presentError:error];
        return;
    }
    
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
	
    if (![file_manager linkItemAtURL:[NSURL fileURLWithPath:self.currentSource]
                               toURL:[NSURL fileURLWithPath:destination] error:&error]) {
        if (error) {
            [NSApp presentError:error];
        }
		[self displayErrorLog:
			 NSLocalizedStringFromTable(@"Failed to make hard link from %@ to %@.", @"ParticularLocalizable", @""),
						self.currentSource, destination];
	}
}

@end
