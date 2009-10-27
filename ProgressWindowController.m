#import "ProgressWindowController.h"
#import "FileProcessor.h"

#define useLog 0

static NSMutableArray* WORKING_WINDOW_CONTROLLERS = nil;

@implementation ProgressWindowController

@synthesize fileProcessor;

+ (void)initialize
{
	if (!WORKING_WINDOW_CONTROLLERS) {
		WORKING_WINDOW_CONTROLLERS = [NSMutableArray new];
	}
}

+ (NSArray *)workingControllers
{
	return WORKING_WINDOW_CONTROLLERS;
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[indicator startAnimation:self];
	isTaskFinished = NO;
}

- (IBAction)okAction:(id)sender
{
	NSString *newpath = [fileProcessor.currentLocation stringByAppendingPathComponent:[newNameField stringValue]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:newpath]) {
		[messageField setStringValue:NSLocalizedString(@"SameNameExists", @"")];
		return;
	}
	[NSApp endSheet:askWindow returnCode:NSOKButton];
}

- (IBAction)replaceAction:(id)sender
{
	[NSApp endSheet:askWindow returnCode:NSOKButton];
}

- (IBAction)cancelAction:(id)sender
{
	[NSApp endSheet:askWindow returnCode:NSCancelButton];
}

- (IBAction)cancelTask:(id)sender
{
	fileProcessor.isCanceled = YES;
}

- (void)setStatusMessage:(NSString *)string
{
	[statusLabel setStringValue:string];
	[statusLabel setHidden:NO];
}

- (void)taskEnded:(id)sender
{
#if useLog
	NSLog(@"task Ended.");
#endif	
	[[NSWorkspace sharedWorkspace] noteFileSystemChanged:[(FileProcessor *)sender currentLocation]];
	[indicator stopAnimation:self];
	isTaskFinished = YES;
	[self close];	
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(FileProcessor *)processor
{
	if (returnCode == NSOKButton) {
		processor.newName = [newNameField stringValue];
	}
	
	[sheet orderOut:self];
	[processor unlock];
}

- (BOOL)panel:(id)sender isValidFilename:(NSString *)filename
{
	if ([fileProcessor.currentSource isEqualToString:filename]) {
		[sender setMessage:NSLocalizedStringFromTable(@"Same to the source item.", @"ParticularLocalizable", @"")];
		return NO;
	}
	
	for (ProgressWindowController* wc in WORKING_WINDOW_CONTROLLERS) {
		if (wc != self) {
			NSString *destination = [wc.fileProcessor.currentLocation stringByAppendingPathComponent:
									 wc.fileProcessor.newName];
			if ([filename isEqualToString:destination]) {
				[sender setMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is busy.", @""), [filename lastPathComponent]]];
				return NO;
			}
		}
	}
	return YES;
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(FileProcessor *)processor
{
	if (returnCode == NSOKButton) {
		NSString *path = [sheet filename];
		processor.newName = [path lastPathComponent];
		processor.currentLocation = [path stringByDeletingLastPathComponent];
	}
	[processor unlock];
}

- (void)askNewName:(FileProcessor *)processor
{
	NSSavePanel *save_panel = [NSSavePanel savePanel];
	[save_panel setDelegate:self];
	[save_panel setMessage:NSLocalizedString(@"SameNameExists", @"")];
	[[self window] orderFront:self];
	//[NSApp activateIgnoringOtherApps:YES];
	[save_panel beginSheetForDirectory:processor.currentLocation
				file:[processor.currentSource lastPathComponent] 
				modalForWindow:[self window] modalDelegate:self
						didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
						   contextInfo:processor];
	[processor lock];
}

- (void)processFiles:(NSArray *)array toLocations:(NSArray *)locations
{
	[self showWindow:self];
	[WORKING_WINDOW_CONTROLLERS addObject:self];
	fileProcessor.sourceItems = array;
	fileProcessor.locations = locations;
	[NSThread detachNewThreadSelector:@selector(startThreadTask:) toTarget:fileProcessor withObject:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
#if useLog
	NSLog(@"windowWillClose");
#endif	
	if (isTaskFinished) {
		[WORKING_WINDOW_CONTROLLERS removeObject:self];
		[super windowWillClose:notification];
		[self autorelease];
	}
}

- (void)dealloc
{
	[super dealloc];
}

@end
