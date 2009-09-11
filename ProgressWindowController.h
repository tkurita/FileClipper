#import <Cocoa/Cocoa.h>
#import "PaletteWindowController.h"
#import "FileProcessor.h"

@interface ProgressWindowController : PaletteWindowController {
	IBOutlet id indicator;
	IBOutlet id askWindow;
	IBOutlet id newNameField;
	IBOutlet FileProcessor* fileProcessor;
	IBOutlet id messageField;
	IBOutlet id statusLabel;
	BOOL isTaskFinished;
}

+ (NSArray *)workingControllers;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)replaceAction:(id)sender;

- (IBAction)cancelTask:(id)sender;
- (void)setStatusMessage:(NSString *)string;

#pragma mark public
- (void)processFiles:(NSArray *)array toLocation:(NSString *)path;


@end
