#import "ProgressWindow.h"


@implementation ProgressWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
	NSWindow* result = [super initWithContentRect:contentRect 
							styleMask:NSBorderlessWindowMask 
							backing:bufferingType 
							defer:flag];
    [result setLevel: NSStatusWindowLevel];
	[result setBackgroundColor:[NSColor clearColor]];
	[result setOpaque:NO];
	[result center];
    return result;
}

@end
