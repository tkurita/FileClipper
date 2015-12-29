//
//  GUIScriptingChecker.m
//  FileClipper
//
//  Created by Tetsuro Kurita on 2015/12/28.
//
//

#import "GUIScriptingChecker.h"
#import "SystemEvents.h"
#import "SystemPreferences.h"

@implementation GUIScriptingChecker

+ (BOOL)check
{
    if (AXIsProcessTrusted() || AXAPIEnabled()) {
        return YES;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    NSComparisonResult result = [[dict objectForKey:@"ProductVersion"] compare:@"10.9" options:NSNumericSearch];
    if (NSOrderedAscending == result) { //10.8 or before
        NSInteger alert_result = [[NSAlert alertWithMessageText:NSLocalizedString(@"GUI Scripting is not enabled.", @"")
                defaultButton:NSLocalizedString(@"Enable GUI Scripting", @"")
              alternateButton:NSLocalizedString(@"Cancel", @"")
                  otherButton:nil
             informativeTextWithFormat:NSLocalizedString(@"Enable GUI Scripting ?", @"")]
                                  runModal];
        if (NSAlertDefaultReturn == alert_result) {
            SystemEventsApplication * system_events_app = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
            system_events_app.UIElementsEnabled = YES;
            return system_events_app.UIElementsEnabled;
        }
    } else {
        NSString *title_string = [NSString stringWithFormat:
                                  NSLocalizedString(@"need accessibility", @""),
                                    [[NSProcessInfo processInfo] processName]];
        NSInteger alert_result = [[NSAlert alertWithMessageText:title_string
                                                  defaultButton:NSLocalizedString(@"Open System Preferences", @"")
                                                alternateButton:NSLocalizedString(@"Deny", @"")
                                                    otherButton:nil
                                      informativeTextWithFormat:
                        NSLocalizedString(@"Grant access", @"")]
                                  runModal];
        if (NSAlertDefaultReturn == alert_result) {
            SystemPreferencesApplication *sys_pre_app = [SBApplication applicationWithBundleIdentifier:@"com.apple.systempreferences"];
            [[[[[sys_pre_app panes] objectWithID:@"com.apple.preference.security"]anchors]
                                                objectWithName:@"Privacy_Accessibility"] reveal];
            [[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.systempreferences"]
              lastObject] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
        }
        
    }
    
    return NO;
}

@end
