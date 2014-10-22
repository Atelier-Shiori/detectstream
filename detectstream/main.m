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

@import ScriptingBridge;
@interface browsercheck : NSObject
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
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        browsercheck * browser = [[browsercheck alloc] init];
        BOOL *check = [browser checkSafari];
        NSMutableArray* pages = [[NSMutableArray alloc]init];
        if (check) {
            SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
            
            SBElementArray* documents = [safari documents];
            for (int i = 0; i< [documents count]; i++) {
                
                SafariDocument* frontDocument = [documents objectAtIndex: i];
                id title = [safari doJavaScript: @"document.title" in: (SafariTab *) frontDocument];
                id url = [safari doJavaScript: @"document.URL" in: (SafariTab *) frontDocument];
                NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:title,@"title",url, @"url",  nil];
                //NSLog(@"%@", page);
                [pages addObject:page];
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


