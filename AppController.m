#import "AppController.h"
#import "ProgressWindow.h"
#import "ProgressWindowController.h"
#import "WindowVisibilityController.h"
#import "FilesInPasteboard.h"
#import "PathExtra.h"
#import "DonationReminder/DonationReminder.h"

#define	useLog 0

static BOOL AUTO_QUIT = YES;

@implementation AppController

- (void)displayErrorLog:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
	NSString *msg = [[[NSString alloc] initWithFormat:format arguments:argumentList] autorelease];
    va_end(argumentList);
	msg = [msg stringByAppendingString:@"\n"];
	[errorWindow orderFront:self];
    NSRange endRange;
	
    endRange.location = [[errorTextView textStorage] length];
    endRange.length = 0;
    [errorTextView replaceCharactersInRange:endRange withString:msg];
    endRange.length = [[errorTextView textStorage] length];
    [errorTextView scrollRangeToVisible:endRange];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
#if useLog
	NSLog(@"applicationShouldTerminateAfterLastWindowClosed");
#endif
	
	return (AUTO_QUIT && ([[ProgressWindowController workingControllers] count] < 1) 
			&& ![errorWindow isVisible] && ![DonationReminder isWindowOpened]);
}

- (void)processAtLocations:(NSArray *)filenames centerPosition:(NSPoint)position
{
	NSMutableArray *locations = [NSMutableArray arrayWithCapacity:[filenames count]];
	
	for (NSString *path in filenames) {
		if (![path isFolder] || [path isPackage]) {
			path = [path stringByDeletingLastPathComponent];
		}
		if (![locations containsObject:path])
			[locations addObject:[path cleanPath]];
	}
	
	NSArray *array = [FilesInPasteboard getContents];
	if (!array) {
		[NSApp activateIgnoringOtherApps:YES];
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
			newposition.x = floor(newposition.x);
			newposition.y = floor(newposition.y);
	#if useLog
			NSLog(@"newposition before shift %f, %f", newposition.x, newposition.y);
	#endif
			NSArray *windows = [NSApp windows];
			for (id a_win in windows) {
				if ((window != a_win) && [a_win isKindOfClass:[ProgressWindow class]]) {
					NSRect rect = [a_win frame];
#if useLog
					NSLog(@"window position %f, %f", rect.origin.x, rect.origin.y);
#endif							
					if (NSEqualPoints(rect.origin, newposition)) {
#if useLog
						NSLog(@"position shifted");
#endif
						newposition.x += rect.size.width/3;
					}
				}
			}
#if useLog
			NSLog(@"newposition after shift %f, %f", newposition.x, newposition.y);
#endif			
			[window setFrameOrigin:newposition];
		} else {
			[window center];
		}
	}
	[wc processFiles:array toLocations:locations];
}

- (void)updateOnFinder:(NSString *)aPath
{
	NSDictionary *err_info = nil;
	NSAppleEventDescriptor *script_result = nil;
	script_result = [finderController executeHandlerWithName:@"update_on_finder"
					   arguments:[NSArray arrayWithObjects:[aPath stringByDeletingLastPathComponent], aPath,  nil] 
							   error:&err_info];
	if (err_info) {
		NSLog([err_info description]);
		NSString *msg = [NSString stringWithFormat:@"AppleScript Error : %@ (%@)",
						 [err_info objectForKey:OSAScriptErrorMessage],
						 [err_info objectForKey:OSAScriptErrorNumber]];
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(nil, msg, @"OK", nil, nil);
	}
}

- (NSPoint)centerOfFinderWindowReturningError:(NSError **)error
{
	NSDictionary *err_info = nil;
	NSAppleEventDescriptor *script_result = nil;
	script_result = [finderController executeHandlerWithName:@"center_of_finderwindow"
												   arguments:nil error:&err_info];
	NSPoint center_position = NSMakePoint(FLT_MAX, FLT_MAX);
	if (err_info) {
		NSLog([err_info description]);
		NSString *msg = [NSString stringWithFormat:@"AppleScript Error : %@ (%@)",
						 [err_info objectForKey:OSAScriptErrorMessage],
						 [err_info objectForKey:OSAScriptErrorNumber]];
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(nil, msg, @"OK", nil, nil);
		NSDictionary *udict = [NSDictionary dictionaryWithObject:msg
														  forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"FileClipperError" code:1 userInfo:udict];
		goto bail;
	}
	
	unsigned int nitem = [script_result numberOfItems];
	
	if (nitem > 1) {
		[[[[script_result descriptorAtIndex:1] coerceToDescriptorType:typeIEEE32BitFloatingPoint] data] getBytes:&center_position.x];
		[[[[script_result descriptorAtIndex:2] coerceToDescriptorType:typeIEEE32BitFloatingPoint] data] getBytes:&center_position.y];
	}
bail:
	return center_position;
}

- (NSString *)insertionLocationReturningError:(NSError **)error
{
	NSDictionary *err_info = nil;
	NSAppleEventDescriptor *script_result = nil;
	script_result = [finderController executeHandlerWithName:@"insertion_location"
												   arguments:nil error:&err_info];
	NSString *location_path = nil;
	if (err_info) {
		NSLog([err_info description]);
		NSString *msg = [NSString stringWithFormat:@"AppleScript Error : %@ (%@)",
						 [err_info objectForKey:OSAScriptErrorMessage],
						 [err_info objectForKey:OSAScriptErrorNumber]];
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(nil, msg, @"OK", nil, nil);
		NSDictionary *udict = [NSDictionary dictionaryWithObject:msg
														  forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"FileClipperError" code:2 userInfo:udict];
		goto bail;
	}
	location_path = [script_result stringValue];
bail:
	return location_path;
}

- (void)processForInsertionLocation
{
#if useLog
	NSLog(@"start processForInsertionLocation");
#endif
	NSError *error = nil;
	NSString *location_path = [self insertionLocationReturningError:&error];
#if useLog
	NSLog(@"location_path %@", location_path);
#endif	
	if (error) goto bail;
	NSPoint center_position = [self centerOfFinderWindowReturningError:&error];
	if (error) goto bail;
	[self processAtLocations:[NSArray arrayWithObject:location_path] centerPosition:center_position];
bail:
	return;	
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
#if useLog
	NSLog(@"applicationOpenUntitledFile");
#endif
	[self processForInsertionLocation];
	return YES;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"CheckGUIScripting"
													 ofType:@"scpt" inDirectory:@"Scripts"];
	NSDictionary *err_info = nil;
	NSAppleScript *guiscripting_checker = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]
																				 error:&err_info];
	if (err_info) {
		NSLog([err_info description]);
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(nil, @"Fail to load CheckGUIScripting.scpt", @"OK", nil, nil);
		[NSApp terminate:self];
		return;
	}
	
	NSAppleEventDescriptor *result = [guiscripting_checker executeAndReturnError:&err_info];
	
	if (err_info) {
		NSLog([err_info description]);
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(nil, @"Fail to chack GUI scripting", @"OK", nil, nil);
		[NSApp terminate:self];
		return;
	}
	
	if ([result descriptorType] != typeTrue) {
		[NSApp terminate:self];
	}
	
	[guiscripting_checker release];
	[DonationReminder remindDonation];
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
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(nil, @"Fail to load FinderController.scpt", @"OK", nil, nil);
		[NSApp terminate:self];
	}
}

- (void)processAtLocationFromPasteboard:(NSPasteboard *)pboard userData:(NSString *)data error:(NSString **)error
{
#if useLog
	NSLog(@"start processAtLocationFromPasteboard");
#endif	
	NSArray *types = [pboard types];
	NSArray *filenames;
	if (![types containsObject:NSFilenamesPboardType] 
		|| !(filenames = [pboard propertyListForType:NSFilenamesPboardType])) {
        *error = NSLocalizedString(@"Error: Pasteboard doesn't contain file paths.",
								   @"Pasteboard couldn't give string.");
        return;
    }
	
	NSPoint center_position = NSMakePoint(FLT_MAX, FLT_MAX);
	NSDictionary *preactiveapp = [[NSWorkspace sharedWorkspace] activeApplication];
	if ( [[preactiveapp objectForKey:@"NSApplicationBundleIdentifier"] isEqualToString:@"com.apple.finder"] ) {
		NSError *error = nil;
		[self insertionLocationReturningError:&error];
		if (!error) 
			center_position = [self centerOfFinderWindowReturningError:&error];
	}
		
	[self processAtLocations:filenames centerPosition:center_position];
}

- (void)dealloc
{
	[finderController release];
	[super dealloc];
}

@end
