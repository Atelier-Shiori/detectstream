//
//  main.m
//  detectstream
//
//  Created by 高町なのは on 2014/10/21.
//  Copyright (c) 2014, Atelier Shiori and James M.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted
//  provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions
//     and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
//     and the following disclaimer in the documentation and/or other materials provided with the
//     distribution.
//
//  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or
//     promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

// Do not want to output timestamp for the output
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

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
    for (a in runningApps) {
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
    for (a in runningApps) {
        if ([[a bundleIdentifier] isEqualToString:@"com.google.Chrome"]) {
            return true;
        }
    }
    return false;
    
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //Initalize Browser Check Object
        browsercheck * browser = [[browsercheck alloc] init];
        NSMutableArray* pages = [[NSMutableArray alloc]init];
        // Check to see Safari is running. If so, add tab's title and url to the array
        if ([browser checkSafari]) {
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
        // Check to see Chrome is running. If so, add tab's title and url to the array
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
        // Check to see if the URL matches the streaming sites
        NSMutableArray * matches = [[NSMutableArray alloc] init];
        if ([pages count]>0) {
            NSError *errRegex = NULL;
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:@"(crunchyroll|daisuki|netflix|hulu)" //Supported Streaming Sites
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&errRegex];
            for (NSDictionary *d in pages) {
                NSString * teststring = [NSString stringWithFormat:@"%@",[d objectForKey:@"url"]];
                NSRange  searchrange = NSMakeRange(0, [teststring length]);
                NSTextCheckingResult *match = [regex firstMatchInString:teststring options:0 range: searchrange];
                NSRange matchRange = [regex rangeOfFirstMatchInString:teststring options:NSMatchingReportProgress range:searchrange];
                if (matchRange.location != NSNotFound) {
                    // Match found, add to match list
                    NSDictionary * n = [[NSDictionary alloc] initWithObjectsAndKeys:[d objectForKey:@"title"], @"title", [d objectForKey:@"browser"], @"browser", [teststring substringWithRange:[match rangeAtIndex:1]] , @"site", nil];
                    [matches addObject:n];
                }
              
            }
        }
        NSMutableArray * final = [[NSMutableArray alloc] init];
        //Perform Regex and sanitize
        if (matches.count > 0) {
            for (NSDictionary *d in matches) {
                NSString * regextitle = [NSString stringWithFormat:@"%@",[d objectForKey:@"title"]];
                NSString * site = [NSString stringWithFormat:@"%@", [d objectForKey:@"site"]];
                NSString * title;
                NSString * episode;
                NSString * season;
                if ([site isEqualToString:@"crunchyroll"]) {
                    //Add Regex Arguments Here
                }
                else if ([site isEqualToString:@"daisuki"]) {
                    //Add Regex Arguments Here
                }
                else if ([site isEqualToString:@"netflix"]) {
                    //Add Regex Arguments Here
                }
                else if ([site isEqualToString:@"hulu"]) {
                    //Add Regex Arguments Here
                }
                // Add to Final Array
                NSDictionary * frecord = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", episode, @"episode", season, @"season", site, @"site", [d objectForKey:@"browser"], @"browser", nil];
                [final addObject:frecord];
            }
        }
        // Generate JSON and output
        NSDictionary * result;
        if (final.count > 0 ) {
            result = [[NSDictionary alloc] initWithObjectsAndKeys:final,@"result", nil];
        }
        else {
            // Empty final array, send null
            result = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"result", nil];
        }

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
        if (!jsonData) {}
        else{
            NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", JSONString);
        }
    }
    return 0;
}

