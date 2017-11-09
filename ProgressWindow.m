#import "ProgressWindow.h"


@implementation ProgressWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	ProgressWindow* result = [super initWithContentRect:contentRect 
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
