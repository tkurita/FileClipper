/* AppController */

#import <Cocoa/Cocoa.h>
#import <OSAKit/OSAScript.h>

@interface AppController : NSObject
{
	IBOutlet id errorWindow;
	IBOutlet id errorTextView;
	OSAScript* finderController;
}

@end
