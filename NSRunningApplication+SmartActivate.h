#import <Cocoa/Cocoa.h>

@interface NSRunningApplication (SmartActivate)
+ (BOOL)activateAppOfIdentifier:(NSString *)targetIdentifier;
+ (BOOL)activateSelf;
@end
