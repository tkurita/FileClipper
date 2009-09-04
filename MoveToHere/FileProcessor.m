#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

- (id)init
{
	if (self = [super init]) {
		char *login_shell = getenv("SHELL");
		self.loginShell = [NSString stringWithUTF8String:login_shell];
	}
	return self;
}

- (void)doTask:(id)sender
{
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	NSFileManager* file_manager = [NSFileManager defaultManager];
	while (source = [enumerator nextObject]) {
		source = [source cleanPath];
		self.newName = [source lastPathComponent];
		if (![[source stringByDeletingLastPathComponent] isEqualToString:location] 
				|| [self resolveNewName:source]) {
			if (![self trySVN:@"mv" withSource:source]) {
				//self.newName = [newName uniqueNameAtLocation:location];
				[file_manager movePath:source toPath:[location stringByAppendingPathComponent:newName] handler:self];
			}
		}
	}
}
@end
