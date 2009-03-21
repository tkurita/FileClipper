#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{
	NSLog(@"awakeFromNib in AppController");
	[_spinIndicator startAnimation:self];
	NSLog(@"end awakeFromNib in AppController");
}

@end
