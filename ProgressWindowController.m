#import "ProgressWindowController.h"
#import "FileProcessor.h"

@implementation ProgressWindowController

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[indicator startAnimation:self];
}

- (IBAction)okAction:(id)sender
{
	NSString *newpath = [fileProcessor.location stringByAppendingPathComponent:[newNameField stringValue]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:newpath]) {
		[messageField setStringValue:NSLocalizedString(@"SameNameExists", @"")];
		return;
	}
	[NSApp endSheet:askWindow returnCode:NSOKButton];
}

- (IBAction)cancelAction:(id)sender
{
	[NSApp endSheet:askWindow returnCode:NSCancelButton];
}

- (void)taskEnded:(id)sender
{
	[indicator stopAnimation:self];
	[self close];	
}


- (void)threadExit:(NSNotification *)aNotification
{
	[self performSelectorOnMainThread:@selector(taskEnded:) withObject:[aNotification object] waitUntilDone:NO];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(FileProcessor *)processor
{
	if (returnCode == NSOKButton) {
		processor.newName = [newNameField stringValue];
	}
	[sheet orderOut:self];
	[processor unlock];
}

- (void)askNewName:(FileProcessor *)processor
{
	[newNameField setStringValue:[processor.currentSource lastPathComponent]];
	[NSApp beginSheet:askWindow modalForWindow:[self window] modalDelegate:self 
		didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:processor];
	[processor lock];
}

- (void)processFiles:(NSArray *)array toLocation:(NSString *)path
{
	[self showWindow:self];
	fileProcessor.sourceItems = array;
	fileProcessor.location = path;
	[NSThread detachNewThreadSelector:@selector(startThreadTask:) toTarget:fileProcessor withObject:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
	[super windowWillClose:notification];
	[self autorelease];
}

- (void)dealloc
{
	[super dealloc];
}

@end
