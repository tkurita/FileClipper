#import "FileProcessor.h"
#import "PathExtra.h"
#import "NDAlias.h"
#import "NDAlias+AliasFile.h"

@implementation FileProcessor

- (void)doTask:(id)sender
{
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	while (source = [enumerator nextObject]) {
		NSString* newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		NSString* destination = [location stringByAppendingPathComponent:newname];
		NDAlias* alias = [NDAlias aliasWithPath:source];
		if (alias) {
			if (![alias writeToFile:destination includeCustomIcon:NO] ) {
				[self displayErrorLog:@"Fail to make alias file at %@.\n", destination];
			}
		} else {
			[self displayErrorLog:@"Fail to make alias for %@.\n", source];
		}
	}
}

@end
