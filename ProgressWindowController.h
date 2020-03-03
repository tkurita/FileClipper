#import <Cocoa/Cocoa.h>
#import "PaletteWindowController/PaletteWindowController.h"
@class FileProcessor;

@interface ProgressWindowController : PaletteWindowController {
	IBOutlet id indicator;
	IBOutlet id askWindow;
	IBOutlet id newNameField;
	IBOutlet id messageField;
	IBOutlet id statusLabel;
	BOOL isTaskFinished;
}

@property (assign) IBOutlet FileProcessor* fileProcessor;

+ (NSArray *)workingControllers;

- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)replaceAction:(id)sender;

- (IBAction)cancelTask:(id)sender;
- (void)setStatusMessage:(NSString *)string;

#pragma mark public
- (void)processFiles:(NSArray *)array toLocations:(NSArray *)locations;
- (void)taskEnded:(id)sender;
- (void)askNewName:(FileProcessor *)processor;

@end
