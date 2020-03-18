#import "ProgressWindowController.h"
#import "FileProcessor.h"
#import "NSRunningApplication+SmartActivate.h"

#define useLog 0

static NSMutableArray* WORKING_WINDOW_CONTROLLERS = nil;

@implementation ProgressWindowController

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
	NSString *newpath = [_fileProcessor.currentLocation stringByAppendingPathComponent:[newNameField stringValue]];
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
	_fileProcessor.isCanceled = YES;
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
		processor.nuName = [newNameField stringValue];
	}
	
	[sheet orderOut:self];
	[processor unlock];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError * _Nullable *)outError;
{
    NSString *filename = [url path];
    if ([_fileProcessor.currentSource isEqualToString:filename]) {
        [sender setMessage:NSLocalizedStringFromTable(@"Same to the source item.", @"ParticularLocalizable", @"")];
        return NO;
    }
    
    for (ProgressWindowController* wc in WORKING_WINDOW_CONTROLLERS) {
        if (wc != self) {
            NSString *destination = [wc.fileProcessor.currentLocation stringByAppendingPathComponent:
                                     wc.fileProcessor.nuName];
            if ([filename isEqualToString:destination]) {
                [sender setMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ is busy.", @""), [filename lastPathComponent]]];
                return NO;
            }
        }
    }
    return YES;
}

- (void)askNewName:(FileProcessor *)processor
{
	NSSavePanel *save_panel = [NSSavePanel savePanel];
	[save_panel setMessage:NSLocalizedString(@"SameNameExists", @"")];
    [save_panel setDirectoryURL:[NSURL fileURLWithPath:processor.currentLocation]];
    [save_panel setNameFieldStringValue:[processor.currentSource lastPathComponent]];
	[[self window] orderFront:self];
	[NSRunningApplication activateSelf];
    [save_panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
     {
         if (result == NSOKButton) {
             NSString *path = [[save_panel URL] path];
             processor.nuName = [path lastPathComponent];
             processor.currentLocation = [path stringByDeletingLastPathComponent];
         }
         [processor unlock];
     }];

	[processor lock];
}

- (void)processFiles:(NSArray *)array toLocations:(NSArray *)locations
{
	[self showWindow:self];
	[WORKING_WINDOW_CONTROLLERS addObject:self];
	_fileProcessor.sourceItems = array;
	_fileProcessor.locations = locations;
	[NSThread detachNewThreadSelector:@selector(startThreadTask:) toTarget:_fileProcessor withObject:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
#if useLog
	NSLog(@"windowWillClose");
#endif	
	if (isTaskFinished) {
		[WORKING_WINDOW_CONTROLLERS removeObject:self];
		[super windowWillClose:notification];
	}
}

@end
