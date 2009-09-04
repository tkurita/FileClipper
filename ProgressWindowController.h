#import <Cocoa/Cocoa.h>
#import "PaletteWindowController.h"

@interface ProgressWindowController : PaletteWindowController {
	IBOutlet id indicator;
	IBOutlet id askWindow;
	IBOutlet id newNameField;
}

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

#pragma mark public
- (void)processFiles:(NSArray *)array toLocation:(NSString *)path;


@end
