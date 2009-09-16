#import "FileProcessor.h"
#import "PathExtra.h"
#import "NDAlias.h"
#import "NDAlias+AliasFile.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	NSString* newname = [[currentSource displayName] uniqueNameAtLocation:currentLocation];
	NSString* destination = [currentLocation stringByAppendingPathComponent:newname];
	NDAlias* alias = [NDAlias aliasWithPath:currentSource];
	if (alias) {
		if (![alias writeToFile:destination includeCustomIcon:YES] ) {
			[self displayErrorLog:
					NSLocalizedStringFromTable(@"Failed to make alias file at %@.", @"ParticularLocalizable", @""), 
					destination];
		}
	} else {
		[self displayErrorLog:
			  NSLocalizedStringFromTable(@"Failed to make alias for %@.", @"ParticularLocalizable", @""), 
			currentSource];
	}
}

@end
