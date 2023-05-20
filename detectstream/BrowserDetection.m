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
#import "Orion.h"

@import ScriptingBridge;

@implementation BrowserDetection
#pragma Constants
NSString *const supportedSites = @"(crunchyroll|animelab|animenewsnetwork|viz|netflix|plex|viewster|funimation|wakanim|myanimelist|hidive|vrv|amazon|tubitv|asiancrush|animedigitalnetwork|sonycrackle|adultswim|hbomax|retrocrush|hulu|peacocktv|disneyplus|youtube|32400)";
NSString *const requiresScraping = @"(crunchyroll)";
NSString *const requiresJavaScript = @"(viewster|amazon|adultswim|hbomax|retrocrush|hulu|peacocktv|disneyplus|crunchyroll|netflix)";

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
NSString *const funimationnewplayer = @"document.querySelector('.meta-overlay__data-block--title').innerHTML + ' | ' + document.querySelector('.meta-overlay__data-block--episode-name').innerHTML;";
NSString *const retrocrushtitle = @"document.querySelector('.title-info').innerHTML;";
NSString *const hulumetadata = @"document.querySelector('.PlayerMetadata__hitRegion').innerHTML";
NSString *const betacrunchyrollmeta = @"document.querySelector('.erc-current-media-info').innerHTML;";
NSString *const betacrunchyrollhistory = @"document.querySelector('.erc-history-content').innerHTML;";
NSString *const peacocktitle = @"document.querySelector('.playback-metadata__container-title').innerHTML";
NSString *const peacockepisode = @"document.querySelector('.playback-metadata__container-episode-metadata-info').innerHTML";
NSString *const disneyplustitle = @"document.querySelector('.title-field').innerHTML";
NSString *const disneyplusmeta = @"document.querySelector('.subtitle-field').innerHTML";
NSString *const netflixcreaterequest = @"var request = new XMLHttpRequest();";
NSString *const netflixrequestfunctions = @"request.open('GET', 'https://www.netflix.com/api/shakti/mre/viewingactivity', true);request.onload = function () {    if (request.status >= 200 && request.status < 400) {        console.log(this.response);    }}";
NSString *const netflixmetadatafunctions = @"request.open('GET', 'https://www.netflix.com/api/shakti/mre/metadata?movieid=(id)', true);request.onload = function () {    if (request.status >= 200 && request.status < 400) {        console.log(this.response);    }}";
NSString *const netflixdorequest = @"request.send();";
NSString *const netflixgetresponse = @"request.response;";
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
                    NSMutableString * DOM = [NSMutableString new];
                    if ([site isEqualToString:@"crunchyroll"]){
                        if ([tab.URL containsString:@"history"]) {
                            NSString *tmpdom = [safari doJavaScript:betacrunchyrollhistory in:tab];
                            if (tmpdom) {
                                [DOM appendString:tmpdom];
                            }
                            else {
                                continue;
                            }
                        }
                        else {
                            NSString *tmpdom = [safari doJavaScript:betacrunchyrollmeta in:tab];
                            if (tmpdom) {
                                [DOM appendString:tmpdom];
                            }
                            else {
                                continue;
                            }
                        }
                    }
                    else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
                        //Include DOM
                        [DOM appendString:[tab source]];
                    }
                    else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresJavaScript]){
                        if ([site isEqualToString:@"viewster"]){
                            [DOM appendString:[NSString stringWithFormat:@"%@ %@", [safari doJavaScript:viewstertitle in:tab], [safari doJavaScript:viewsterepisode in:tab]]];
                        }
                        else if ([site isEqualToString:@"amazon"] ){
                            NSString *playicon = [safari doJavaScript:amazonplayicon in:tab];
                            NSString *pauseicon = [safari doJavaScript:amazonpauseicon in:tab];
                            if (pauseicon || (playicon && !pauseicon)) {
                                [DOM appendString:[NSString stringWithFormat:@"%@ - %@", [safari doJavaScript:amazontitle in:tab], [safari doJavaScript:amazonsubtitle in:tab]]];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"peacocktv"] ){
                            NSString *title = [safari doJavaScript:peacocktitle in:tab];
                            NSString *episode = [safari doJavaScript:peacockepisode in:tab];
                            if (title) {
                                [DOM appendString:[NSString stringWithFormat:@"{\"title\":\"%@\",\"episode\":\"%@\",}",title, episode ? episode : @""]];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"adultswim"]) {
                            NSString *seasonidentifier = [safari doJavaScript:adultswimepisode in:tab];
                            if (seasonidentifier) {
                                [DOM appendString:seasonidentifier];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"hbomax"]) {
                            NSString *tmpdom = [safari doJavaScript:@"document.documentElement.innerHTML" in:tab];
                            if (tmpdom) {
                                [DOM appendString:tmpdom];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"netflix"] && [[ezregex alloc] findMatches:tab.URL pattern:@"\\/watch\\/\\d+"].count > 0) {
                            [safari doJavaScript:netflixcreaterequest in:tab];
                            [safari doJavaScript:netflixrequestfunctions in:tab];
                            [safari doJavaScript:netflixdorequest in:tab];
                            sleep(1);
                            long episodenum = [self getNetflixMovieID:(NSString *)[safari doJavaScript:netflixgetresponse in:tab]];
                            NSString *njavascript = [netflixmetadatafunctions stringByReplacingOccurrencesOfString:@"(id)" withString:@(episodenum).stringValue];
                            [safari doJavaScript:njavascript in:tab];
                            [safari doJavaScript:netflixdorequest in:tab];
                            sleep(1);
                            NSString *tmpdom = [safari doJavaScript:netflixgetresponse in:tab];
                            if (tmpdom) {
                                [DOM appendString:[self parseMetaData:tmpdom]];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"retrocrush"]){
                            NSString *tmpdom = [safari doJavaScript:retrocrushtitle in:tab];
                            if (tmpdom) {
                                [DOM appendString:tmpdom];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"hulu"]){
                            NSString *tmpdom = [safari doJavaScript:hulumetadata in:tab];
                            if (tmpdom) {
                                [DOM appendString:tmpdom];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"disneyplus"]) {
                            NSString *title = [safari doJavaScript:disneyplustitle in:tab];
                            NSString *metadata = [safari doJavaScript:disneyplusmeta in:tab];
                            if (title) {
                                [DOM appendString:[NSString stringWithFormat:@"{\"title\":\"%@\",\"meta\":\"%@\",}",title, metadata ? metadata : @""]];
                            }
                            else {
                                continue;
                            }
                        }
                    }
                    else if ([site isEqualToString:@"funimation"] && [[ezregex alloc] findMatches:tab.URL pattern:@"account"].count > 0) {
                        NSString *historyitem = [safari doJavaScript:funimationhistory in:tab];
                        if (historyitem) {
                            [DOM appendString:historyitem];
                            site = @"funimation";
                        }
                        else {
                            continue;
                        }
                    }
                    else if ([site isEqualToString:@"funimation"] && [[ezregex alloc] findMatches:tab.URL pattern:@"v\\/.*\\/.*"].count > 0) {
                        NSString *metadata = [safari doJavaScript:funimationnewplayer in:tab];
                        if (metadata) {
                            [DOM appendString:metadata];
                            site = @"funimation";
                        }
                        else {
                            continue;
                        }
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
                NSMutableString * DOM = [NSMutableString new];
                if (site.length > 0) {
                    if (![browserstring isEqualToString:@"Opera"]) {
                        // Note: Opera can't do Javascript execution via Apple Script
                        if ([site isEqualToString:@"crunchyroll"]){
                            if ([tab.URL containsString:@"history"]) {
                                NSString *tmpdom = [tab executeJavascript:betacrunchyrollhistory];
                                if (tmpdom) {
                                    [DOM appendString:tmpdom];
                                }
                                else {
                                    continue;
                                }
                            }
                            else {
                            NSString *tmpdom = [tab executeJavascript:betacrunchyrollmeta];
                                if (tmpdom) {
                                    [DOM appendString:tmpdom];
                                }
                                else {
                                    continue;
                                }
                            }
                        }
                        else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
                            // Get source code using Javascript
                            [DOM appendString:(NSString *)[tab executeJavascript:@"document.documentElement.innerHTML"]];
                        }
                        else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresJavaScript]){
                            if ([site isEqualToString:@"viewster"]){
                                [DOM appendString:[NSString stringWithFormat:@"%@ %@", [tab executeJavascript:viewstertitle], [tab executeJavascript:viewsterepisode]]];
                            }
                            else if ([site isEqualToString:@"peacocktv"] ){
                                NSString *title = [tab executeJavascript:peacocktitle];
                                NSString *episode = [tab executeJavascript:peacockepisode];
                                if (title) {
                                    [DOM appendString:[NSString stringWithFormat:@"{\"title\":\"%@\",\"episode\":\"%@\",}",title, episode ? episode : @""]];
                                }
                                else {
                                    continue;
                                }
                            }
                            else if ([site isEqualToString:@"amazon"]){
                                NSString *playicon = [tab executeJavascript:amazonplayicon];
                                NSString *pauseicon = [tab executeJavascript:amazonpauseicon];
                                if (pauseicon || (playicon && !pauseicon)) {
                                    [DOM appendString:[NSString stringWithFormat:@"%@ - %@", [tab executeJavascript:amazontitle], [tab executeJavascript:amazonsubtitle]]];
                                }
                                else {
                                    continue;
                                }
                            }
                            else if ([site isEqualToString:@"adultswim"]) {
                                NSString *seasonidentifier = [tab executeJavascript:adultswimepisode];
                                if (seasonidentifier) {
                                    [DOM appendString:seasonidentifier];
                                }
                                else {
                                    continue;
                                }
                            }
                            else if ([site isEqualToString:@"hbomax"]) {
                                NSString *tmpdom = [tab executeJavascript:@"document.documentElement.innerHTML"];
                                if (tmpdom) {
                                    [DOM appendString:tmpdom];
                                }
                                else {
                                    continue;
                                }
                            }
                            else if ([site isEqualToString:@"retrocrush"]){
                                NSString *tmpdom = [tab executeJavascript:retrocrushtitle];
                                if (tmpdom) {
                                    [DOM appendString:tmpdom];
                                }
                                else {
                                    continue;
                                }
                            }
                            else if ([site isEqualToString:@"hulu"]){
                                NSString *tmpdom = [tab executeJavascript:hulumetadata];
                                if (tmpdom) {
                                    [DOM appendString:tmpdom];
                                }
                                else {
                                    continue;
                                }
                            }
                            else if ([site isEqualToString:@"disneyplus"]) {
                                NSString *title = [tab executeJavascript:disneyplustitle];
                                NSString *metadata = [tab executeJavascript:disneyplusmeta];
                                if (title) {
                                    [DOM appendString:[NSString stringWithFormat:@"{\"title\":\"%@\",\"meta\":\"%@\",}",title, metadata ? metadata : @""]];
                                }
                                else {
                                    continue;
                                }
                            }
                        }
                        else if ([site isEqualToString:@"netflix"] && [[ezregex alloc] findMatches:tab.URL pattern:@"\\/watch\\/\\d+"].count > 0) {
                            [tab executeJavascript:netflixcreaterequest];
                            [tab executeJavascript:netflixrequestfunctions];
                            [tab executeJavascript:netflixdorequest];
                            sleep(1);
                            long episodenum = [self getNetflixMovieID:(NSString *)[tab executeJavascript:netflixgetresponse]];
                            NSString *njavascript = [netflixmetadatafunctions stringByReplacingOccurrencesOfString:@"(id)" withString:@(episodenum).stringValue];
                            [tab executeJavascript:njavascript];
                            [tab executeJavascript:netflixdorequest];
                            sleep(1);
                            NSString *tmpdom = [tab executeJavascript:netflixgetresponse];
                            if (tmpdom) {
                                [DOM appendString:[self parseMetaData:tmpdom]];
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"funimation"] && [[ezregex alloc] findMatches:tab.URL pattern:@"account"].count > 0 && ![browserstring isEqualToString:@"Opera"]) {
                            NSString *historyitem = (NSString *)[tab executeJavascript:funimationhistory];
                            if (historyitem) {
                                [DOM appendString:historyitem];
                                site = @"funimation";
                            }
                            else {
                                continue;
                            }
                        }
                        else if ([site isEqualToString:@"funimation"] && [[ezregex alloc] findMatches:tab.URL pattern:@"v\\/.*\\/.*"].count > 0 && ![browserstring isEqualToString:@"Opera"]) {
                            NSString *metadata = (NSString *)[tab executeJavascript:funimationnewplayer];
                            if (metadata) {
                                [DOM appendString:metadata];
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
     // Orion Support
     if ([browser checkIdentifier:@"com.kagi.kagimacOS"]) {
          OrionApplication* orion = [SBApplication applicationWithBundleIdentifier:@"com.kagi.kagimacOS"];
          NSString * browserstring = @"Orion";
          
          SBElementArray * windows = [orion windows];
          for (NSUInteger i = 0; i < [windows count]; i++) {
               OrionWindow * window = windows[i];
               SBElementArray * tabs = [window tabs];
               for (NSUInteger t = 0 ; t < [tabs count]; t++) {
                    OrionTab * tab = tabs[t];
                    NSString * site = [browser checkURL:tab.URL];
                    if (site.length > 0) {
                         NSMutableString * DOM = [NSMutableString new];
                         OrionDocument *doc = window.document;
                         bool isActiveTabInWindow = [window.document.URL isEqualToString:tab.URL];
                         if ([site isEqualToString:@"crunchyroll"]){
                              if ([tab.URL containsString:@"history"] && isActiveTabInWindow) {
                                   NSString *tmpdom = [orion doJavaScript:betacrunchyrollhistory in:doc];
                                   if (tmpdom) {
                                        [DOM appendString:tmpdom];
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else {
                                   if (isActiveTabInWindow) {
                                        NSString *tmpdom = [orion doJavaScript:betacrunchyrollmeta in:doc];
                                        if (tmpdom) {
                                             [DOM appendString:tmpdom];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                         }
                         else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresScraping]){
                              if (isActiveTabInWindow) {
                                   //Include DOM
                                   [DOM appendString:[orion doJavaScript:@"document.documentElement.innerHTML" in:doc]];
                              }
                              else {
                                   continue;
                              }

                         }
                         else if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:requiresJavaScript]){
                              if ([site isEqualToString:@"viewster"]){
                                   if (isActiveTabInWindow) {
                                        [DOM appendString:[NSString stringWithFormat:@"%@ %@", [orion doJavaScript:viewstertitle in:doc], [orion doJavaScript:viewsterepisode in:doc]]];
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"amazon"] ){
                                   if (isActiveTabInWindow) {
                                        NSString *playicon = [orion doJavaScript:amazonplayicon in:doc];
                                        NSString *pauseicon = [orion doJavaScript:amazonpauseicon in:doc];
                                        if (pauseicon || (playicon && !pauseicon)) {
                                             [DOM appendString:[NSString stringWithFormat:@"%@ - %@", [orion doJavaScript:amazontitle in:doc], [orion doJavaScript:amazonsubtitle in:doc]]];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"peacocktv"] ){
                                   if (isActiveTabInWindow) {
                                        NSString *title = [orion doJavaScript:peacocktitle in:doc];
                                        NSString *episode = [orion doJavaScript:peacockepisode in:doc];
                                        if (title) {
                                             [DOM appendString:[NSString stringWithFormat:@"{\"title\":\"%@\",\"episode\":\"%@\",}",title, episode ? episode : @""]];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"adultswim"]) {
                                   if (isActiveTabInWindow) {
                                        NSString *seasonidentifier = [orion doJavaScript:adultswimepisode in:doc];
                                        if (seasonidentifier) {
                                             [DOM appendString:seasonidentifier];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"hbomax"]) {
                                   if (isActiveTabInWindow) {
                                        NSString *tmpdom = [orion doJavaScript:@"document.documentElement.innerHTML" in:doc];
                                        if (tmpdom) {
                                             [DOM appendString:tmpdom];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"netflix"] && [[ezregex alloc] findMatches:tab.URL pattern:@"\\/watch\\/\\d+"].count > 0) {
                                   if (isActiveTabInWindow) {
                                        [orion doJavaScript:netflixcreaterequest in:doc];
                                        [orion doJavaScript:netflixrequestfunctions in:doc];
                                        [orion doJavaScript:netflixdorequest in:doc];
                                        sleep(1);
                                        long episodenum = [self getNetflixMovieID:(NSString *)[orion doJavaScript:netflixgetresponse in:doc]];
                                        NSString *njavascript = [netflixmetadatafunctions stringByReplacingOccurrencesOfString:@"(id)" withString:@(episodenum).stringValue];
                                        [orion doJavaScript:njavascript in:doc];
                                        [orion doJavaScript:netflixdorequest in:doc];
                                        sleep(1);
                                        NSString *tmpdom = [orion doJavaScript:netflixgetresponse in:doc];
                                        if (tmpdom) {
                                             [DOM appendString:[self parseMetaData:tmpdom]];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"retrocrush"]){
                                   if (isActiveTabInWindow) {
                                        NSString *tmpdom = [orion doJavaScript:retrocrushtitle in:doc];
                                        if (tmpdom) {
                                             [DOM appendString:tmpdom];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"hulu"]){
                                   if (isActiveTabInWindow) {
                                        NSString *tmpdom = [orion doJavaScript:hulumetadata in:doc];
                                        if (tmpdom) {
                                             [DOM appendString:tmpdom];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else if ([site isEqualToString:@"disneyplus"]) {
                                   if (isActiveTabInWindow) {
                                        NSString *title = [orion doJavaScript:disneyplustitle in:doc];
                                        NSString *metadata = [orion doJavaScript:disneyplusmeta in:doc];
                                        if (title) {
                                             [DOM appendString:[NSString stringWithFormat:@"{\"title\":\"%@\",\"meta\":\"%@\",}",title, metadata ? metadata : @""]];
                                        }
                                        else {
                                             continue;
                                        }
                                   }
                                   else {
                                        continue;
                                   }
                              }
                         }
                         else if ([site isEqualToString:@"funimation"] && [[ezregex alloc] findMatches:tab.URL pattern:@"account"].count > 0) {
                              if (isActiveTabInWindow) {
                                   NSString *historyitem = [orion doJavaScript:funimationhistory in:doc];
                                   if (historyitem) {
                                        [DOM appendString:historyitem];
                                        site = @"funimation";
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else {
                                   continue;
                              }
                         }
                         else if ([site isEqualToString:@"funimation"] && [[ezregex alloc] findMatches:tab.URL pattern:@"v\\/.*\\/.*"].count > 0) {
                              if (isActiveTabInWindow) {
                                   NSString *metadata = [orion doJavaScript:funimationnewplayer in:doc];
                                   if (metadata) {
                                        [DOM appendString:metadata];
                                        site = @"funimation";
                                   }
                                   else {
                                        continue;
                                   }
                              }
                              else {
                                   continue;
                              }
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

+ (long)getNetflixMovieID:(NSString *)viewhistory {
    NSError *error;
    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:[viewhistory dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        return -1;
    }
    else {
    NSArray *vieweditems = metadata[@"viewedItems"];
        if (vieweditems.count > 0) {
            return ((NSNumber *)vieweditems[0][@"movieID"]).longValue;
        }
    }
    return -1;
}

+ (NSString *)parseMetaData:(NSString *)metadatajson {
    NSMutableDictionary *tmp = [NSMutableDictionary new];
    NSError *error;
    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:[metadatajson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        return nil;
    }
    else {
        long currentepisode = ((NSNumber *)metadata[@"video"][@"currentEpisode"]).longValue;
        NSArray *seasons = metadata[@"video"][@"seasons"];
        bool finish = false;
        for (int i=0; i < seasons.count; i++) {
            NSDictionary *season = seasons[i];
            for (NSDictionary * episode in season[@"episodes"]) {
                if (currentepisode == ((NSNumber *)episode[@"episodeId"]).longValue) {
                    tmp[@"title"] = metadata[@"video"][@"title"];
                    tmp[@"season"] = season[@"seq"];
                    tmp[@"episode"] = episode[@"seq"];
                    finish = true;
                    break;
                }
            }
            if (finish) {
                break;
            }
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmp
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];

        if (!jsonData) {
            NSLog(@"Got an error: %@", error);
            return nil;
        } else {
           return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}
@end
