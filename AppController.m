#import "AppController.h"
#import "ProgressWindowController.h"
#import "WindowVisibilityController.h"
#import "FilesInPasteboard.h"

#define	 useLog 1

@implementation AppController

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	NSLog(@"applicationShouldTerminateAfterLastWindowClosed");
	return YES;
}

- (void)processAtLocation:(NSString *)path centerPosition:(NSPoint)position
{
	NSArray *array = [FilesInPasteboard getContents];
	if (!array) {
		NSRunAlertPanel (NSLocalizedString(@"NoFilesInClipboard", @""), @"", @"OK", nil, nil);
		return;
	}
	
	ProgressWindowController *wc = [[ProgressWindowController alloc] initWithWindowNibName:@"ProgressWindow"];
	[wc bindApplicationsFloatingOnForKey:@"applicationsFloatingOn"];
	[wc useFloating];
#if useLog	
	NSLog(@"%f, %f", position.x, position.y);
#endif	
	if (position.x != FLT_MAX) {
		NSEnumerator *enumerator = [[NSScreen screens] objectEnumerator];
		NSScreen *screen;
		while (screen = [enumerator nextObject]) {
			NSRect screen_rect = [screen frame];
			if (NSPointInRect(position, screen_rect)) {
#if useLog
				NSLog(@"screen width %f height %f", screen_rect.size.width, screen_rect.size.height);
				NSLog(@"screen x %f y %f", screen_rect.origin.x, screen_rect.origin.y);
#endif				
				position.y = screen_rect.size.height-position.y;
				break;
			}
		}
#if useLog
		NSLog(@"%f, %f", position.x, position.y);
#endif
		NSWindow *window = [wc window];
		NSRect frame = [window frame];
		NSPoint newposition = NSMakePoint(position.x - frame.size.width/2, 
										position.y - frame.size.height/2);
#if useLog
		NSLog(@"%f, %f", newposition.x, newposition.y);
#endif
		[window setFrameOrigin:newposition];
		
	}
	[wc processFiles:array toLocation:path];
}


- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"applicationDidBecomeActive");
#endif
	if (launchedFromServices) {
		launchedFromServices = NO;
		return;
	}

	NSDictionary *err_info = nil;
	NSAppleEventDescriptor *script_result = nil;
	script_result = [finderController executeHandlerWithName:@"insertion_location"
																arguments:nil error:&err_info];
	if (err_info) {
		NSLog([err_info description]);
		NSString *msg = [NSString stringWithFormat:@"AppleScript Error : %@ (%@)",
						 [err_info objectForKey:OSAScriptErrorMessage],
						 [err_info objectForKey:OSAScriptErrorNumber]];
		NSRunAlertPanel (nil, msg, @"OK", nil, nil);
		goto bail;
	}
	
	NSString *location_path = [script_result stringValue];
	
	script_result = [finderController executeHandlerWithName:@"center_of_finderwindow"
												arguments:nil error:&err_info];
	
	if (err_info) {
		NSLog([err_info description]);
		NSString *msg = [NSString stringWithFormat:@"AppleScript Error : %@ (%@)",
						 [err_info objectForKey:OSAScriptErrorMessage],
						 [err_info objectForKey:OSAScriptErrorNumber]];
		NSRunAlertPanel (nil, msg, @"OK", nil, nil);
		goto bail;
	}
		
	unsigned int nitem = [script_result numberOfItems];
	NSPoint center_position = NSMakePoint(FLT_MAX, FLT_MAX);
	if (nitem > 1) {
		[[[[script_result descriptorAtIndex:1] coerceToDescriptorType:typeIEEE32BitFloatingPoint] data] getBytes:&center_position.x];
		[[[[script_result descriptorAtIndex:2] coerceToDescriptorType:typeIEEE32BitFloatingPoint] data] getBytes:&center_position.y];
	}

	[self processAtLocation:location_path centerPosition:center_position];
bail:
	return;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"applicationDidFinishLaunching");	
}

- (void)awakeFromNib
{
	launchedFromServices = NO;
	NSString *defaults_plist = [[NSBundle mainBundle] pathForResource:@"FactorySettings" ofType:@"plist"];
	NSDictionary *factory_defaults = [NSDictionary dictionaryWithContentsOfFile:defaults_plist];
	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	[user_defaults registerDefaults:factory_defaults];
	[NSApp setServicesProvider:self];
	[PaletteWindowController setVisibilityController:[WindowVisibilityController sharedWindowVisibilityController]];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"FinderController"
													 ofType:@"scpt" inDirectory:@"Scripts"];
	NSDictionary *err_info = nil;
	finderController = [[OSAScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]
																	 error:&err_info];
	if (err_info) {
		NSLog([err_info description]);
	}	
}

- (void)processAtLocationFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
#if useLog
	NSLog(@"start processAtLocationFromPasteboard");
#endif
	launchedFromServices = YES;
	NSArray *types = [pboard types];
	NSArray *filenames;
	if (![types containsObject:NSFilenamesPboardType] 
		|| !(filenames = [pboard propertyListForType:NSFilenamesPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain file paths.",
								   @"Pasteboard couldn't give string.");
        return;
    }
	
	[self application:NSApp openFiles:filenames];
	//[NSApp activateIgnoringOtherApps:YES];
}

- (void)dealloc
{
	[finderController release];
	[super dealloc];
}

@end
