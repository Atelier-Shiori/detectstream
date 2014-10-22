//
//  main.m
//  detectstream
//
//  Created by 高町なのは on 2014/10/21.
//  Copyright (c) 2014年 Chikorita157's Anime Blog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/SBApplication.h>
#import "Safari.h"
#import "Google Chrome.h"

@import ScriptingBridge;
@interface browsercheck : NSObject
-(BOOL)checkChrome;
-(BOOL)checkSafari;
@end

@implementation browsercheck
-(BOOL)checkSafari {
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSArray *runningApps = [ws runningApplications];
    NSRunningApplication *a;
    for (a in runningApps ) {
        if ([[a bundleIdentifier] isEqualToString:@"com.apple.Safari"]) {
            return true;
        }
    }
    return false;
    
}
-(BOOL)checkChrome {
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSArray *runningApps = [ws runningApplications];
    NSRunningApplication *a;
    for (a in runningApps ) {
        if ([[a bundleIdentifier] isEqualToString:@"com.google.Chrome"]) {
            return true;
        }
    }
    return false;
    
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        browsercheck * browser = [[browsercheck alloc] init];
        BOOL check = [browser checkSafari];
        NSMutableArray* pages = [[NSMutableArray alloc]init];
        if (check) {
            SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
            SBElementArray * windows = [safari windows];
            for (int i = 0; i < [windows count]; i++) {
                SafariWindow * window = [windows objectAtIndex:i];
                SBElementArray * tabs = [window tabs];
                for (int i = 0 ; i < [tabs count]; i++) {
                    SafariTab * tab = [tabs objectAtIndex:i];
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab name],@"title",[tab URL], @"url",  @"Safari", @"browser",  nil];
                    [pages addObject:page];
                }
            }

        }
        if ([browser checkChrome]) {
            GoogleChromeApplication * chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
            SBElementArray * windows = [chrome windows];
            for (int i = 0; i < [windows count]; i++) {
                GoogleChromeWindow * window = [windows objectAtIndex:i];
                SBElementArray * tabs = [window tabs];
                for (int i = 0 ; i < [tabs count]; i++) {
                    GoogleChromeTab * tab = [tabs objectAtIndex:i];
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab title],@"title",[tab URL], @"url", @"Chrome", @"browser",  nil];
                    [pages addObject:page];
                }
            }
        }
                //NSLog(@"%@", pages);
        if ([pages count]>0) {
            NSError *errRegex = NULL;
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:@"\\(crunchyroll|daisuki|netflix|hulu)\b"
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&errRegex];
            NSString *addresses = @"";
            for (int i = 0; i < [pages count]; i++) {
                NSDictionary * d = [pages objectAtIndex:i];
                addresses = [NSString stringWithFormat:@"%@ - %@", addresses, [d objectForKey:@"url"]];
            }
            /*NSRange   searchedRange = NSMakeRange(0, [addresses length]);
            for (NSTextCheckingResult* match in matches) {
                
            }*/
        }
        NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:pages,@"result", nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
        if (!jsonData) {
            
        }
        else{
            NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", JSONString);
        }
    }
    return 0;
}


