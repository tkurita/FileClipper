#import "FileProcessor.h"
#import "PathExtra.h"
#import "NDAlias.h"
#import "NDAlias+AliasFile.h"

@implementation FileProcessor

- (void) startTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	while (source = [enumerator nextObject]) {
		NSString* newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		NSString* destination = [location stringByAppendingPathComponent:newname];
		NDAlias* alias = [NDAlias aliasWithPath:source];
		if (alias) {
			if (![alias writeToFile:destination includeCustomIcon:NO] ) {
				NSLog(@"Fail to make alias file at %@", destination);
			}
		} else {
			NSLog(@"Fail to make alias for %@", source);
		}
	}
	[pool release];
}
@end
