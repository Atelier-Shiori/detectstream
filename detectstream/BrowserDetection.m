//
//  BrowserDetection.m
//  detectstream
//
//  Created by 高町なのは on 2015/02/09.
//  Copyright (c) 2015年 Chikorita157's Anime Blog. All rights reserved.
//
//  This class gathers all the page titles, url and DOM (if necessary) from open browsers.
//  Only returns applicable streaming sites.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "BrowserDetection.h"
#import "browsercheck.h"
#import "ezregex.h"
#import <ScriptingBridge/SBApplication.h>
// Browsers
#import "Safari.h"
#import "Google Chrome.h"
#import "OmniWeb.h"
#import "Roccat.h"

@import ScriptingBridge;

@implementation BrowserDetection
+(NSArray *)getPages{
    //Initalize Browser Check Object
    browsercheck * browser = [[browsercheck alloc] init];
    NSMutableArray * pages = [[NSMutableArray alloc] init];
    /*
     Browser Detection
     */
    // Check to see Safari is running. If so, add tab's title and url to the array
    for (int s = 0; s <2; s++) {
        SafariApplication* safari;
        NSString * browserstring;
        switch (s) {
            case 0:
                if (![browser checkIdentifier:@"com.apple.Safari"]) {
                    continue;
                }
                safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
                browserstring = @"Safari";
                break;
            case 1:
                if (![browser checkIdentifier:@"org.webkit.nightly.WebKit"]) {
                    continue;
                }
                safari  = [SBApplication applicationWithBundleIdentifier:@"org.webkit.nightly.WebKit"];
                browserstring = @"Webkit";
                break;
            default:
                break;
        }
        
        SBElementArray * windows = [safari windows];
        for (int i = 0; i < [windows count]; i++) {
            SafariWindow * window = [windows objectAtIndex:i];
            SBElementArray * tabs = [window tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                SafariTab * tab = [tabs objectAtIndex:i];
                NSString * site = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:@"(netflix)"]){
                        //Include DOM
                        DOM = [tab source];
                    }
                    else{
                        DOM = nil;
                    }
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab name],@"title",[tab URL], @"url",  browserstring, @"browser", site, @"site", DOM, @"DOM",  nil];
                    [pages addObject:page];
                }
                else{
                    continue;
                }
                
            }
        }
    }
    // Check to see Chrome is running. If so, add tab's title and url to the array
    if ([browser checkIdentifier:@"com.google.Chrome"]) {
        GoogleChromeApplication * chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
        SBElementArray * windows = [chrome windows];
        for (int i = 0; i < [windows count]; i++) {
            GoogleChromeWindow * window = [windows objectAtIndex:i];
            SBElementArray * tabs = [window tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                GoogleChromeTab * tab = [tabs objectAtIndex:i];
                NSString * site  = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:@"(netflix)"]){
                        // Chrome does not provide DOM, exclude
                        continue;
                    }
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab title],@"title",[tab URL], @"url", @"Chrome", @"browser",  site, @"site", nil, @"DOM", nil];
                    [pages addObject:page];
                }
                else{
                    continue;
                }
            }
        }
    }
    // Check to see Omniweb is running. If so, add tab's title and url to the array
    if ([browser checkIdentifier:@"com.omnigroup.OmniWeb5"]||[browser checkIdentifier:@"com.omnigroup.OmniWeb6"]) {
        OmniWebApplication * omniweb;
        if ([browser checkIdentifier:@"com.omnigroup.OmniWeb5"]) {
            // For version 5
            omniweb = [SBApplication applicationWithBundleIdentifier:@"com.omnigroup.OmniWeb5"];
        }
        else{
            // For version 6
            omniweb = [SBApplication applicationWithBundleIdentifier:@"com.omnigroup.OmniWeb6"];
        }
        SBElementArray * browsers = [omniweb browsers];
        for (int i = 0; i < [browsers count]; i++) {
            OmniWebBrowser * obrowser = [browsers objectAtIndex:i];
            SBElementArray * tabs = [obrowser tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                OmniWebTab * tab = [tabs objectAtIndex:i];
                NSString * site  = [browser checkURL:[tab address]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab address] pattern:@"(netflix)"]){
                        // Add Source
                        DOM = [tab source];
                    }
                    else{
                        DOM = nil;
                    }
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab title],@"title",[tab address], @"url", @"OmniWeb", @"browser", site, @"site", DOM, @"DOM", nil];
                    [pages addObject:page];
                }
                else{
                    continue;
                }
            }
        }
    }
    // Check to see Roccat is running. If so, add tab's title and url to the array
    if ([browser checkIdentifier:@"org.Runecats.Roccat"]) {
        RoccatApplication * roccat = [SBApplication applicationWithBundleIdentifier:@"org.Runecats.Roccat"];
        SBElementArray * browsers = [roccat browserWindows];
        for (int i = 0; i < [browsers count]; i++) {
            RoccatBrowserWindow * rbrowser = [browsers objectAtIndex:i];
            SBElementArray * tabs = [rbrowser tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                RoccatTab * tab = [tabs objectAtIndex:i];
                NSString * site  = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:@"(netflix)"]){
                        // Include DOM
                        DOM = [tab source];
                    }
                    else{
                        DOM = nil;
                    }
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab title],@"title",[tab URL], @"url", @"Roccat", @"browser", site, @"site", DOM, @"DOM", nil];
                    [pages addObject:page];
                }
                else{
                    continue;
                }
            }
        }
    }
    return pages;
}
@end
