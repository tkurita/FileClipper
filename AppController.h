/* AppController */

#import <Cocoa/Cocoa.h>
#import <OSAKit/OSAScript.h>

@interface AppController : NSObject
{
	BOOL launchedFromServices;
	OSAScript* finderController;
}

@end
