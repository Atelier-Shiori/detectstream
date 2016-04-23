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
#import "ezregex.h"
#import <ScriptingBridge/SBApplication.h>
// Browsers
#import "Safari.h"
#import "Google Chrome.h"
#import "OmniWeb.h"
#import "Roccat.h"

@import ScriptingBridge;

@implementation BrowserDetection
#pragma Constants
NSString *const supportedSites = @"(crunchyroll|daisuki|animelab|animenewsnetwork|viz|netflix|plex|viewster|funimation|wakanim|32400)";
NSString *const requiresScraping = @"(netflix|funimation)";

#pragma Methods
+(NSArray *)getPages{
    //Initalize Browser Check Object
    BrowserDetection * browser = [[self alloc] init];
    NSMutableArray * pages = [[NSMutableArray alloc] init];
    /*
     Browser Detection
     */
    // Check to see Safari is running. If so, add tab's title and url to the array
    for (int s = 0; s <3; s++) {
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
            case 2:
                if (![browser checkIdentifier:@"com.apple.SafariTechnologyPreview"]) {
                    continue;
                }
                safari  = [SBApplication applicationWithBundleIdentifier:@"com.apple.SafariTechnologyPreview"];
                browserstring = @"Safari Tech Preview";
                break;
            default:
                break;
        }
        
        SBElementArray * windows = [safari windows];
        for (int i = 0; i < [windows count]; i++) {
            SafariWindow * window = windows[i];
            SBElementArray * tabs = [window tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                SafariTab * tab = tabs[i];
                NSString * site = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
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
    for (int s = 0; s <3; s++) {
            GoogleChromeApplication * chrome;
            NSString * browserstring;
            switch (s) {
                case 0:
                    if (![browser checkIdentifier:@"com.google.Chrome"]) {
                        continue;
                    }
                    chrome = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
                    browserstring = @"Chrome";
                    break;
                case 1:
                    if (![browser checkIdentifier:@"org.chromium.Chromium"]) {
                        continue;
                    }
                    chrome  = [SBApplication applicationWithBundleIdentifier:@"org.chromium.Chromium"];
                    browserstring = @"Chromium";
                    break;
                case 2:
                    if (![browser checkIdentifier:@"com.google.Chrome.canary"]) {
                        continue;
                    }
                    chrome  = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome.canary"];
                    browserstring = @"Chrome Canary";
                    break;
                default:
                    break;
            }
        SBElementArray * windows = [chrome windows];
        for (int i = 0; i < [windows count]; i++) {
            GoogleChromeWindow * window = windows[i];
            SBElementArray * tabs = [window tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                GoogleChromeTab * tab = tabs[i];
                NSString * site  = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
                        // Chrome does not provide DOM, exclude
                        continue;
                    }
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab title],@"title",[tab URL], @"url", browserstring, @"browser",  site, @"site", nil, @"DOM", nil];
                    [pages addObject:page];
                }
                else{
                    continue;
                }
            }
        }
    }
    // Check to see Omniweb is running. If so, add tab's title and url to the array
    for (int s = 0; s <2; s++) {
        OmniWebApplication * omniweb;
        switch (s) {
            case 0:
                if (![browser checkIdentifier:@"com.omnigroup.OmniWeb5"]) {
                    continue;
                }
                // For version 5
                omniweb = [SBApplication applicationWithBundleIdentifier:@"com.omnigroup.OmniWeb5"];
                break;
            case 1:
                if (![browser checkIdentifier:@"com.omnigroup.OmniWeb6"]) {
                    continue;
                }
                // For version 6
                omniweb = [SBApplication applicationWithBundleIdentifier:@"com.omnigroup.OmniWeb6"];
                break;
            default:
                break;
        }
        SBElementArray * browsers = [omniweb browsers];
        for (int i = 0; i < [browsers count]; i++) {
            OmniWebBrowser * obrowser = browsers[i];
            SBElementArray * tabs = [obrowser tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                OmniWebTab * tab = tabs[i];
                NSString * site  = [browser checkURL:[tab address]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab address] pattern:requiresScraping]){
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
            RoccatBrowserWindow * rbrowser = browsers[i];
            SBElementArray * tabs = [rbrowser tabs];
            for (int i = 0 ; i < [tabs count]; i++) {
                RoccatTab * tab = tabs[i];
                NSString * site  = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
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
-(BOOL)checkIdentifier:(NSString*)identifier{
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSArray *runningApps = [ws runningApplications];
    NSRunningApplication *a;
    for (a in runningApps) {
        if ([[a bundleIdentifier] isEqualToString:identifier]) {
            return true;
        }
    }
    return false;
}
-(NSString *)checkURL:(NSString *)url{
    NSString * site = [[[ezregex alloc] init] findMatch:url pattern:supportedSites rangeatindex:0];
    if ([site isEqualToString:@"32400"]) {
        //Plex local port, return plex
        return @"plex";
    }
    return site;
}

@end
