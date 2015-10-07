#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	//NSString* newname = [[currentSource displayName] uniqueNameAtLocation:currentLocation];
	if (![self resolveNewName:currentSource]) {
		return;
	}
	NSString* destination = [currentLocation stringByAppendingPathComponent:self.newName];
    NSError *error = nil;
	NSData *bd = [[NSURL foleURLWithPath:currentSource]
                  bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    if (error) {
        [NSApp presentError:error];
        [self displayErrorLog:
         NSLocalizedStringFromTable(@"Failed to make alias for %@.", @"ParticularLocalizable", @""),
         currentSource];
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
