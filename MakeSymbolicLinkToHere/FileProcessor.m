#import "FileProcessor.h"
#import "PathExtra.h"
#include <unistd.h>

@implementation FileProcessor

- (void)setLocation:(NSString *)path {
	[path retain];
	[location autorelease];
	location = path;
}

- (void)setSourceItems:(NSArray *)array {
	[array retain];
	[sourceItems autorelease];
	sourceItems = array;
}

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path {
	self = [self init];
	[self setLocation:path];
	[self setSourceItems:array];
	return self;
}

- (void) startTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	while (source = [enumerator nextObject]) {
		NSString *newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		if (symlink([source fileSystemRepresentation], 
					[[location stringByAppendingPathComponent:newname] fileSystemRepresentation]) != 0) {
			NSLog(@"Error to make symbolic link : %d", errno);
		}
	}
	[pool release];
}
@end
