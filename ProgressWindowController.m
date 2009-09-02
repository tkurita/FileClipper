#import "ProgressWindowController.h"
#import "FileProcessor.h"

@implementation ProgressWindowController

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];
	[indicator startAnimation:self];
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
