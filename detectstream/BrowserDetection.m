//
//  BrowserDetection.m
//  detectstream
//
//  Created by 高町なのは on 2015/02/09.
//  Copyright 2014-2020 Atelier Shiori, James Moy. All rights reserved. Code licensed under MIT License.
//
//  This class gathers all the page titles, url and DOM (if necessary) from open browsers.
//  Only returns applicable streaming sites.
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
NSString *const supportedSites = @"(crunchyroll|animelab|animenewsnetwork|viz|netflix|plex|viewster|funimation|wakanim|myanimelist|hidive|vrv|amazon|tubitv|asiancrush|animedigitalnetwork|sonycrackle|adultswim|32400)";
NSString *const requiresScraping = @"(netflix|crunchyroll)";
NSString *const requiresJavaScript = @"(viewster|amazon|adultswim)";

#pragma Javascript Constants
// From https://github.com/matthewdias/media-strategies/blob/master/strategies/viewster.js
NSString *const viewstertitle = @"document.querySelector('.title').innerHTML";
NSString *const viewsterepisode = @"document.querySelector('.playing').parentElement.parentElement.querySelector('.slide-title > .episode-title').innerHTML";
// Amazon Prime Video/Anime Strike
NSString *const amazontitle = @"document.querySelector('.title').innerHTML";
NSString *const amazonsubtitle = @"document.querySelector('.subtitle').innerHTML";
NSString *const amazonplayicon = @"document.querySelector('.playIcon').innerHTML";
NSString *const amazonpauseicon = @"document.querySelector('.pausedIcon').innerHTML";
NSString *const adultswimepisode = @"document.querySelector('.show-content__seasons').innerHTML";
NSString *const funimationhistory = @"document.querySelector('.history-item').innerHTML;";

#pragma Methods
+ (NSArray *)getPages {
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
        for (NSUInteger i = 0; i < [windows count]; i++) {
            SafariWindow * window = windows[i];
            SBElementArray * tabs = [window tabs];
            for (NSUInteger t = 0 ; t < [tabs count]; t++) {
                SafariTab * tab = tabs[t];
                NSString * site = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    NSString * DOM = @"";
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
                        //Include DOM
                        DOM = [tab source];
                    }
                    else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresJavaScript]){
                        if ([site isEqualToString:@"viewster"]){
                            DOM = [NSString stringWithFormat:@"%@ %@", [safari doJavaScript:viewstertitle in:tab], [safari doJavaScript:viewsterepisode in:tab]];
                        }
                        else if ([site isEqualToString:@"amazon"] ){
                            NSString *playicon = [safari doJavaScript:amazonplayicon in:tab];
                            NSString *pauseicon = [safari doJavaScript:amazonpauseicon in:tab];
                            if (pauseicon || (playicon && !pauseicon)) {
                                DOM = [NSString stringWithFormat:@"%@ - %@", [safari doJavaScript:amazontitle in:tab], [safari doJavaScript:amazonsubtitle in:tab]];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"adultswim"]) {
                            NSString *seasonidentifier = [safari doJavaScript:adultswimepisode in:tab];
                            if (seasonidentifier) {
                                DOM = seasonidentifier;
                            }
                            else {
                                continue;
                            }
                        }
                    }
                    else if ([site isEqualToString:@"funimation"] && [tab.URL rangeOfString:@"funimation.com/account" options:NSCaseInsensitiveSearch].length != NSNotFound) {
                        NSString *historyitem = [safari doJavaScript:funimationhistory in:tab];
                        if (historyitem) {
                            DOM = historyitem;
                            site = @"funimation";
                        }
                        else {
                            continue;
                        }
                    }
                    else{
                        DOM = @"";
                    }
                    NSDictionary * page = @{@"title": [tab name], @"url": [tab URL], @"browser": browserstring, @"site": site, @"DOM": DOM};
                    [pages addObject:page];
                }
                else{
                    continue;
                }
                
            }
        }
    }
    // Check to see Chrome is running. If so, add tab's title and url to the array
    for (int s = 0; s < 8; s++) {
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
                case 3:
                    if (![browser checkIdentifier:@"com.microsoft.edgemac.Canary"]) {
                        continue;
                    }
                    chrome  = [SBApplication applicationWithBundleIdentifier:@"com.microsoft.edgemac.Canary"];
                    browserstring = @"Microsoft Edge Canary";
                    break;
                case 4:
                    if (![browser checkIdentifier:@"com.microsoft.edgemac"]) {
                        continue;
                    }
                    chrome  = [SBApplication applicationWithBundleIdentifier:@"com.microsoft.edgemac"];
                    browserstring = @"Microsoft Edge";
                    break;
                case 5:
                    if (![browser checkIdentifier:@"com.microsoft.edgemac.Beta"]) {
                        continue;
                    }
                    chrome  = [SBApplication applicationWithBundleIdentifier:@"com.microsoft.edgemac.Beta"];
                    browserstring = @"Microsoft Edge";
                    break;
                case 6:
                    if (![browser checkIdentifier:@"com.brave.Browser"]) {
                        continue;
                    }
                    chrome  = [SBApplication applicationWithBundleIdentifier:@"com.brave.Browser"];
                    browserstring = @"Brave Browser";
                    break;
                case 7:
                    if (![browser checkIdentifier:@"com.operasoftware.Opera"]) {
                        continue;
                    }
                    chrome  = [SBApplication applicationWithBundleIdentifier:@"com.operasoftware.Opera"];
                    browserstring = @"Opera";
                    break;
                default:
                    break;
            }
        SBElementArray * windows = [chrome windows];
        for (NSUInteger i = 0; i < [windows count]; i++) {
            GoogleChromeWindow * window = windows[i];
            SBElementArray * tabs = [window tabs];
            for (NSUInteger t = 0 ; t < [tabs count]; t++) {
                GoogleChromeTab * tab = tabs[t];
                NSString * site  = [browser checkURL:[tab URL]];
                NSString * DOM = @"";
                if (site.length > 0) {
                    if (![browserstring isEqualToString:@"Opera"]) {
                        // Note: Opera can't do Javascript execution via Apple Script
                        if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
                            // Get source code using Javascript
                            DOM = (NSString *)[tab executeJavascript:@"document.documentElement.innerHTML"];
                        }
                        else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresJavaScript]){
                            if ([site isEqualToString:@"viewster"]){
                                DOM = [NSString stringWithFormat:@"%@ %@", [tab executeJavascript:viewstertitle], [tab executeJavascript:viewsterepisode]];
                            }
                            else if ([site isEqualToString:@"amazon"]){
                                NSString *playicon = [tab executeJavascript:amazonplayicon];
                                NSString *pauseicon = [tab executeJavascript:amazonpauseicon];
                                if (pauseicon || (playicon && !pauseicon)) {
                                    DOM = [NSString stringWithFormat:@"%@ - %@", [tab executeJavascript:amazontitle], [tab executeJavascript:amazonsubtitle]];
                                }
                                else {
                                    continue;
                                }
                            }
                            else if ([site isEqualToString:@"adultswim"]) {
                                NSString *seasonidentifier = [tab executeJavascript:adultswimepisode];
                                if (seasonidentifier) {
                                    DOM = seasonidentifier;
                                }
                                else {
                                    continue;
                                }
                            }
                        }
                        else if ([site isEqualToString:@"funimation"] && [tab.URL rangeOfString:@"funimation.com/account" options:NSCaseInsensitiveSearch].length != NSNotFound && ![browserstring isEqualToString:@"Opera"]) {
                            NSString *historyitem = (NSString *)[tab executeJavascript:funimationhistory];
                            if (historyitem) {
                                DOM = historyitem;
                                site = @"funimation";
                            }
                            else {
                                continue;
                            }
                        }
                    }
                    NSDictionary * page = @{@"title": [tab title], @"url": [tab URL], @"browser": browserstring, @"site": site, @"DOM": DOM ? DOM : @""};
                    [pages addObject:page];
                }
                else {
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
        for (NSUInteger i = 0; i < [browsers count]; i++) {
            OmniWebBrowser * obrowser = browsers[i];
            SBElementArray * tabs = [obrowser tabs];
            for (NSUInteger t = 0 ; t < [tabs count]; t++) {
                OmniWebTab * tab = tabs[t];
                NSString * site  = [browser checkURL:[tab address]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab address] pattern:requiresScraping]){
                        // Add Source
                        DOM = [tab source];
                    }
                    else if ([tab.address rangeOfString:@"funimation.com/account" options:NSCaseInsensitiveSearch].length != NSNotFound) {
                        continue;
                    }
                    else if ([[[ezregex alloc] init] checkMatch:[tab address] pattern:requiresJavaScript]){
                        // Can't return javascript output, continue
                        continue;
                    }
                    else{
                        DOM = @"";
                    }
                    NSDictionary * page = @{@"title": [tab title], @"url": [tab address], @"browser": @"OmniWeb", @"site": site, @"DOM": DOM};
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
        for (NSUInteger i = 0; i < [browsers count]; i++) {
            RoccatBrowserWindow * rbrowser = browsers[i];
            SBElementArray * tabs = [rbrowser tabs];
            for (NSUInteger t = 0 ; t < [tabs count]; t++) {
                RoccatTab * tab = tabs[t];
                NSString * site  = [browser checkURL:[tab URL]];
                if (site.length > 0) {
                    NSString * DOM;
                    if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
                        // Include DOM
                        DOM = [tab source];
             
                    }
                    else if ([tab.URL rangeOfString:@"funimation.com/account" options:NSCaseInsensitiveSearch].length != NSNotFound) {
                        continue;
                    }
                    else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresJavaScript]){
                        // Javascript Applescript function does not return value, continue
                        continue;
                    }
                    else{
                        DOM = @"";
                    }
                    NSDictionary * page = @{@"title": [tab title], @"url": [tab URL], @"browser": @"Roccat", @"site": site, @"DOM": DOM};
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
- (BOOL)checkIdentifier:(NSString*)identifier {
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
- (NSString *)checkURL:(NSString *)url {
    NSString * site = [[[ezregex alloc] init] findMatch:url pattern:supportedSites rangeatindex:0];
    if ([site isEqualToString:@"32400"]) {
        //Plex local port, return plex
        return @"plex";
    }
    return site;
}

@end
