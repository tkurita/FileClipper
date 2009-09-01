#import <Cocoa/Cocoa.h>
#import "PaletteWindowController.h"

@interface ProgressWindowController : PaletteWindowController {
	IBOutlet id indicator;
}

#pragma mark public
- (void)processFiles:(NSArray *)array toLocation:(NSString *)path;


@end
