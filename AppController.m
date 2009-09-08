#import "AppController.h"
#import "ProgressWindowController.h"
#import "WindowVisibilityController.h"
#import "FilesInPasteboard.h"
#import "PathExtra.h"

#define	useLog 1

static BOOL processStarted = NO;
static BOOL IS_FIRST_PROCESS = YES;

@implementation AppController

- (void)displayErrorLog:(NSString *)aText
{
	[errorWindow orderFront:self];
    NSRange endRange;
	
    endRange.location = [[errorTextView textStorage] length];
    endRange.length = 0;
    [errorTextView replaceCharactersInRange:endRange withString:aText];
    endRange.length = [errorTextView length];
    [errorTextView scrollRangeToVisible:endRange];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
#if useLog
	NSLog(@"applicationShouldTerminateAfterLastWindowClosed");
#endif
	
	return ([[ProgressWindowController workingControllers] count] < 1);
}

- (void)processAtLocation:(NSString *)path centerPosition:(NSPoint)position
{
	NSArray *array = [FilesInPasteboard getContents];
	if (!array) {
		NSRunAlertPanel(NSLocalizedString(@"NoFilesInClipboard", @""), @"", @"OK", nil, nil);
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
		if (position.x != FLT_MAX) {
			NSRect frame = [window frame];
			NSPoint newposition = NSMakePoint(position.x - frame.size.width/2, 
											position.y - frame.size.height/2);
	#if useLog
			NSLog(@"%f, %f", newposition.x, newposition.y);
	#endif
			[window setFrameOrigin:newposition];
		} else {
			[window center];
		}
	}
	[wc processFiles:array toLocation:path];
}

- (void)updateOnFinder:(NSString *)aPath
{
	NSDictionary *err_info = nil;
	NSAppleEventDescriptor *script_result = nil;
	script_result = [finderController executeHandlerWithName:@"update_on_finder"
								   arguments:[NSArray arrayWithObject:aPath] error:&err_info];
	if (err_info) {
		NSLog([err_info description]);
		NSString *msg = [NSString stringWithFormat:@"AppleScript Error : %@ (%@)",
						 [err_info objectForKey:OSAScriptErrorMessage],
						 [err_info objectForKey:OSAScriptErrorNumber]];
		NSRunAlertPanel(nil, msg, @"OK", nil, nil);
	}
}

- (void)processForInsertionLocation
{
	NSDictionary *err_info = nil;
	NSAppleEventDescriptor *script_result = nil;
	script_result = [finderController executeHandlerWithName:@"insertion_location"
												   arguments:nil error:&err_info];
	if (err_info) {
		NSLog([err_info description]);
		NSString *msg = [NSString stringWithFormat:@"AppleScript Error : %@ (%@)",
						 [err_info objectForKey:OSAScriptErrorMessage],
						 [err_info objectForKey:OSAScriptErrorNumber]];
		NSRunAlertPanel(nil, msg, @"OK", nil, nil);
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
		NSRunAlertPanel(nil, msg, @"OK", nil, nil);
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


- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"applicationDidBecomeActive");
#endif
	if (processStarted) {
		processStarted = NO;
		return;
	}
	NSLog(@"start process in applicationDidBecomeActive");
	[self processForInsertionLocation];
}


- (void)delayedProcess:(id)sender
{
	if (!IS_FIRST_PROCESS) {
#if useLog		
		NSLog(@"process stated is detected in delayedProcess");
#endif		
		return;
	}
	
	NSLog(@"start in delayedProcess");
	processStarted = YES;
	IS_FIRST_PROCESS = NO;
	[NSApp activateIgnoringOtherApps:YES];
	[self processForInsertionLocation];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!AXAPIEnabled())
    {
		[NSApp activateIgnoringOtherApps:YES];
		int ret = NSRunAlertPanel(NSLocalizedString(@"GUIScriptingIsNotEnabled", @""), 
								  NSLocalizedString(@"AskLaunchPreferences", @""), 
								  NSLocalizedString(@"LauchSystemPreferences", @""),
								  NSLocalizedString(@"Cancel",""), @"");
		switch (ret)
        {
            case NSAlertDefaultReturn:
                [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/UniversalAccessPref.prefPane"];
                break;
			default:
                break;
        }
        
		[NSApp terminate:self];
		return;
    }

	[self performSelector:@selector(delayedProcess:) withObject:self afterDelay:0.3];
}

- (void)awakeFromNib
{
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
		NSRunAlertPanel(nil, @"Fail to load FinderController.scpt", @"OK", nil, nil);
		[NSApp terminate:self];
	}
}

- (void)processAtLocationFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
#if useLog
	NSLog(@"start processAtLocationFromPasteboard");
#endif
	processStarted = YES;
	IS_FIRST_PROCESS = NO;
	NSArray *types = [pboard types];
	NSArray *filenames;
	if (![types containsObject:NSFilenamesPboardType] 
		|| !(filenames = [pboard propertyListForType:NSFilenamesPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain file paths.",
								   @"Pasteboard couldn't give string.");
        return;
    }
	NSPoint center_position = NSMakePoint(FLT_MAX, FLT_MAX);
	NSString *location = [filenames objectAtIndex:0];
	if (![location isFolder] || [location isPackage]) {
		location = [location stringByDeletingLastPathComponent];
	}
	[NSApp activateIgnoringOtherApps:YES];
	[self processAtLocation:location centerPosition:center_position];
}

- (void)dealloc
{
	[finderController release];
	[super dealloc];
}

@end
