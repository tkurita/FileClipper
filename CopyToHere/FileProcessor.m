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
		if ([self resolveNewName:source]) {
			if (![self trySVN:@"cp" withSource:source]) {
				NSString *destination = [location stringByAppendingPathComponent:newName];
				NSLog(@"Copy source : %@", source);
				NSLog(@"Copy destination : %@", destination);
				[file_manager copyPath:source toPath:destination handler:self];
				[[NSWorkspace sharedWorkspace] noteFileSystemChanged:location]; // it looks not effects
				[[NSApp delegate] performSelectorOnMainThread:@selector(updateOnFinder:) withObject:destination waitUntilDone:NO];
			}
		}
	}
}
@end
