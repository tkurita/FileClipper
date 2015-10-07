#import "NSRunningApplication+SmartActivate.h"

@implementation NSRunningApplication (SmartActivate)

+ (BOOL)activateAppOfIdentifier:(NSString *)targetIdentifier
{
    return [[[NSRunningApplication runningApplicationsWithBundleIdentifier:targetIdentifier]
             lastObject] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

+ (BOOL)activateSelf
{
    return [[NSRunningApplication currentApplication]
             activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

@end
