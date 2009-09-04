#import "FileProcessor.h"
#import "PathExtra.h"

@implementation FileProcessor

NSTask* makeSVNTask(NSArray* arguments)
{
	NSString* svncommand = [[NSUserDefaults standardUserDefaults] stringForKey:@"SVNCommand"];
	NSTask* task = [NSTask new];
	[task setLaunchPath:svncommand];
	[task setArguments:arguments];
	[task setStandardError:[NSPipe pipe]];
	[task setStandardOutput:[NSPipe pipe]];
	return [task autorelease];
}

- (BOOL)trySVN:(NSString *)source
{
	NSTask* svntask = makeSVNTask([NSArray arrayWithObjects:@"info", source, nil]);
	BOOL result = NO;
	[svntask launch];
	[svntask waitUntilExit];
	if ([svntask terminationStatus] != 0) {
		goto bail;
	}
	
	svntask = makeSVNTask([NSArray arrayWithObjects:@"info", location, nil]);
	[svntask launch];
	[svntask waitUntilExit];
	
	if ([svntask terminationStatus] != 0) {
		goto bail;
	}

	svntask = makeSVNTask([NSArray arrayWithObjects:@"mv", source, 
						   [location stringByAppendingPathComponent:newName], nil]);
	[svntask launch];
	[svntask waitUntilExit];
	if ([svntask terminationStatus] != 0) {
		NSLog([[[NSString alloc] initWithData:[[[svntask standardError] fileHandleForReading] availableData]
						encoding:NSUTF8StringEncoding] autorelease]);
		goto bail;
	}
	
	result = YES;
bail:
	return result;
}

- (void)startTask:(id)sender
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [sourceItems objectEnumerator];
	NSString* source;
	NSFileManager* file_manager = [NSFileManager defaultManager];
	while (source = [enumerator nextObject]) {
		source = [source cleanPath];
		self.newName = [source lastPathComponent];
		if (![[source stringByDeletingLastPathComponent] isEqualToString:location] 
				|| [self resolveNewName:source]) {
			if (![self trySVN:source]) {
				//self.newName = [newName uniqueNameAtLocation:location];
				[file_manager movePath:source toPath:[location stringByAppendingPathComponent:newName] handler:self];
			}
		}
	}
	[pool release];
}
@end
