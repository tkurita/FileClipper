#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	if (![self resolveNewName: self.currentSource]) {
		return;
	}
	NSString* destination = [self.currentLocation stringByAppendingPathComponent:self.nuName];
    NSError *error = nil;
	NSData *bd = [[NSURL fileURLWithPath:self.currentSource]
                    bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                    includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    if (error) {
        [NSApp presentError:error];
        [self displayErrorLog:
            NSLocalizedStringFromTable(@"Failed to make alias for %@.", @"ParticularLocalizable", @""),
            self.currentSource];
        return;
    }
    
    if ([destination fileExists]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:destination error:&error]) {
            [self displayErrorLog:
                NSLocalizedStringFromTable(@"Failed to remove a file at %@.", @"ParticularLocalizable", @""),
                destination];
            return;
        }
        
    }
    
    if (![NSURL writeBookmarkData:bd toURL:[NSURL fileURLWithPath:destination]
                          options:NSURLBookmarkCreationSuitableForBookmarkFile  error:&error]) {
        [NSApp performSelectorOnMainThread:@selector(presentError:)
                                withObject:error waitUntilDone:NO];
        [self displayErrorLog:
            NSLocalizedStringFromTable(@"Failed to make alias file at %@.", @"ParticularLocalizable", @""),
            destination];
    }
}

@end
