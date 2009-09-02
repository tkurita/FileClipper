/* AppController */

#import <Cocoa/Cocoa.h>
#import <OSAKit/OSAScript.h>

@interface AppController : NSObject
{
	IBOutlet id errorWindow;
	IBOutlet id errorTextView;
	BOOL launchedFromServices;
	OSAScript* finderController;
}

@end
