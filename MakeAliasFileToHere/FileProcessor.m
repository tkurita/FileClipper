#import "FileProcessor.h"
#import "PathExtra.h"
#import "NDAlias.h"
#import "NDAlias+AliasFile.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	NSString* newname = [[currentSource lastPathComponent] uniqueNameAtLocation:currentLocation];
	NSString* destination = [currentLocation stringByAppendingPathComponent:newname];
	NDAlias* alias = [NDAlias aliasWithPath:currentSource];
	if (alias) {
		if (![alias writeToFile:destination includeCustomIcon:NO] ) {
			[self displayErrorLog:
					NSLocalizedStringFromTable(@"Failed to make alias file at %@.", @"ParticularLocalizable", @""), 
					destination];
		}
	} else {
		[self displayErrorLog:
			  NSLocalizedString(@"Fail to make alias for %@.", @"ParticularLocalizable", @""), 
			currentSource];
	}
}

@end
