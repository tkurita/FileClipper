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
	[NSApp endSheet:askWindow returnCode:NSOKButton];
}

- (IBAction)cancelAction:(id)sender
{
	[NSApp endSheet:askWindow returnCode:NSCancelButton];
}

- (void)taskEnded:(NSThread *)thread
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSThreadWillExitNotification object:thread];
	[thread release];
	[indicator stopAnimation:self];
	[self close];	
}

- (void)threadExit:(NSNotification *)aNotification
{
	[self performSelectorOnMainThread:@selector(taskEnded:) withObject:[aNotification object] waitUntilDone:NO];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(FileProcessor *)processor
{
	NSLog(@"sheetDidEnd");
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
	FileProcessor* processor = [[FileProcessor alloc] initWithSourceItems:array toLocation:path owner:self];
	NSThread *thread = [[NSThread alloc] initWithTarget:[processor autorelease]
											   selector:@selector(startTask:) object:self];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(threadExit:) 
											 name:NSThreadWillExitNotification object:thread];
	[thread start];
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
