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
                  bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    if (error) {
        [NSApp presentError:error];
        [self displayErrorLog:
         NSLocalizedStringFromTable(@"Failed to make alias for %@.", @"ParticularLocalizable", @""),
         self.currentSource];
        return;
    }
    
    
    if (![NSURL writeBookmarkData:bd toURL:[NSURL fileURLWithPath:destination]
                          options: NSURLBookmarkCreationSuitableForBookmarkFile  error:&error]) {
        [NSApp presentError:error];
        [self displayErrorLog:
         NSLocalizedStringFromTable(@"Failed to make alias file at %@.", @"ParticularLocalizable", @""),
         destination];
    }
}

@end
