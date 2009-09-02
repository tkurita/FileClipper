#import "FileProcessor.h"
#import "PathExtra.h"

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

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	NSLog([errorInfo description]);
	return NO;
}

- (void) startTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	NSFileManager* file_manager = [NSFileManager defaultManager];
	while (source = [enumerator nextObject]) {
		NSString *newname = [[source lastPathComponent] uniqueNameAtLocation:location];
		NSString *destination = [location stringByAppendingPathComponent:newname];
		if (![file_manager linkPath:source toPath:destination handler:self] ){
			NSLog(@"Fail to make hard link from %@ to %@", source, destination);
		}
	}
	[pool release];
}
@end
