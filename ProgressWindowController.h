#import <Cocoa/Cocoa.h>
#import "PaletteWindowController.h"
#import "FileProcessor.h"

@interface ProgressWindowController : PaletteWindowController {
	IBOutlet id indicator;
	IBOutlet id askWindow;
	IBOutlet id newNameField;
	IBOutlet FileProcessor* fileProcessor;
	IBOutlet id messageField;
	BOOL isTaskFinished;
}

+ (NSArray *)workingControllers;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)cancelTask:(id)sender;

#pragma mark public
- (void)processFiles:(NSArray *)array toLocation:(NSString *)path;


@end
