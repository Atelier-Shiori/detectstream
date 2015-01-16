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
-(BOOL)checkWebkit;
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
-(BOOL)checkWebkit {
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSArray *runningApps = [ws runningApplications];
    NSRunningApplication *a;
    for (a in runningApps) {
        if ([[a bundleIdentifier] isEqualToString:@"org.webkit.nightly.WebKit"]) {
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
//
// This class is used to simplify regex
//
@interface ezregex : NSObject
-(BOOL)checkMatch:(NSString *)string pattern:(NSString *)pattern;
-(NSString *)searchreplace:(NSString *)string pattern:(NSString *)pattern;
-(NSString *)findMatch:(NSString *)string pattern:(NSString *)pattern rangeatindex:(int)ri;
@end

@implementation ezregex

-(BOOL)checkMatch:(NSString *)string pattern:(NSString *)pattern{
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    NSRange  searchrange = NSMakeRange(0, [string length]);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:searchrange];
    if (matchRange.location != NSNotFound)
        return true;
        else
        return false;
}
-(NSString *)searchreplace:(NSString *)string pattern:(NSString *)pattern{
    NSError *errRegex = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&errRegex];
    NSString * newString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    return newString;
}
-(NSString *)findMatch:(NSString *)string pattern:(NSString *)pattern rangeatindex:(int)ri{
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    NSRange  searchrange = NSMakeRange(0, [string length]);
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range: searchrange];
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:searchrange];
    if (matchRange.location != NSNotFound){
        return [string substringWithRange:[match rangeAtIndex:ri]];
    }
    return @"";
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //Initalize Browser Check Object
        browsercheck * browser = [[browsercheck alloc] init];
        NSMutableArray* pages = [[NSMutableArray alloc]init];
/* 
 Browser Detection
 */
        // Check to see Safari is running. If so, add tab's title and url to the array
            for (int s = 0; s <2; s++) {
                SafariApplication* safari;
                NSString * browserstring;
                switch (s) {
                    case 0:
                        if (![browser checkSafari]) {
                            continue;
                        }
                        safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
                        browserstring = @"Safari";
                        break;
                    case 1:
                        if (![browser checkWebkit]) {
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
						NSString * DOM;
						if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:@"(netflix)"]){
							//Include DOM
							DOM = [tab source];
						}
						else{
							DOM = nil;
						}
                        NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab name],@"title",[tab URL], @"url",  browserstring, @"browser", DOM, @"DOM",  nil];
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
					if ([[[ezregex alloc] init] checkMatch:[tab URL] pattern:@"(netflix)"]){
						// Chrome does not provide DOM, exclude
						continue;
					}
                    NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:[tab title],@"title",[tab URL], @"url", @"Chrome", @"browser", nil, @"DOM",  nil];
                    [pages addObject:page];
                }
            }
        }
        // Check to see if the URL matches the streaming sites
        NSMutableArray * matches = [[NSMutableArray alloc] init];
        if ([pages count]>0) {
            NSError *errRegex = NULL;
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:@"(crunchyroll|daisuki|animelab|animenewsnetwork|viz|netflix)" //Supported Streaming Sites
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&errRegex];
            for (NSDictionary *d in pages) {
                NSString * teststring = [NSString stringWithFormat:@"%@",[d objectForKey:@"url"]];
                NSRange  searchrange = NSMakeRange(0, [teststring length]);
                NSTextCheckingResult *match = [regex firstMatchInString:teststring options:0 range: searchrange];
                NSRange matchRange = [regex rangeOfFirstMatchInString:teststring options:NSMatchingReportProgress range:searchrange];
                if (matchRange.location != NSNotFound) {
                    // Match found, add to match list
                    NSDictionary * n = [[NSDictionary alloc] initWithObjectsAndKeys:[d objectForKey:@"title"], @"title", teststring , @"url" ,[d objectForKey:@"browser"], @"browser", [teststring substringWithRange:[match rangeAtIndex:1]] , @"site",[d objectForKey:@"DOM"] , @"DOM", nil];
                    [matches addObject:n];
                }
              
            }
        }
        NSMutableArray * final = [[NSMutableArray alloc] init];
        ezregex * ez = [[ezregex alloc] init];
        //Perform Regex and sanitize
        if (matches.count > 0) {
            for (NSDictionary *m in matches) {
                NSString * regextitle = [NSString stringWithFormat:@"%@",[m objectForKey:@"title"]];
                NSString * url = [NSString stringWithFormat:@"%@", [m objectForKey:@"url"]];
                NSString * site = [NSString stringWithFormat:@"%@", [m objectForKey:@"site"]];
                NSString * title;
                NSString * tmpepisode;
                NSString * tmpseason;
                if ([site isEqualToString:@"crunchyroll"]) {
                    //Add Regex Arguments Here
                    if ([ez checkMatch:url pattern:@"\\b[^/]+\\/episode-[0-9]+.*-[0-9]+$"]||[ez checkMatch:url pattern:@"\\b[^/]+\\/.*-movie-[0-9]+$"]) {
                        //Perform Sanitation
                        regextitle = [ez searchreplace:regextitle pattern:@"\\bCrunchyroll - Watch\\s"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\b\\s-\\sMovie\\s-\\sMovie"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\b\\sEpisode"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\D-\\s*.*$"];
                        tmpepisode = [ez findMatch:regextitle pattern:@"(\\d\\d\\d|\\d\\d|\\d)" rangeatindex:0];
                        title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpseason = @"0"; //not supported
                    }
                    else
                    continue;
                }
                else if ([site isEqualToString:@"daisuki"]) {
                    //Add Regex Arguments for daisuki.net
                    if ([ez checkMatch:url pattern:@"^(?=.*\\banime\\b)(?=.*\\bwatch\\b).*"]) {
                        //Perform Sanitation
                        regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\sDAISUKI\\b"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\D\\D\\s*.*\\s-"];
                        tmpepisode = [ez findMatch:regextitle pattern:@"(\\d\\d\\d|\\d\\d)" rangeatindex:0];
                        title = [ez findMatch:regextitle pattern:@"\\b\\D([^\\n\\r]*)$" rangeatindex:0];
                        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpseason = @"0"; //not supported
                    }
                    else
                        continue; // Invalid address
                }
                // Following came from Taiga - https://github.com/erengy/taiga/ //
                else if ([site isEqualToString:@"animelab"]) {
                    if ([ez checkMatch:url pattern:@"(\\/player\\/)"]) {
                        regextitle = [ez searchreplace:regextitle pattern:@"AnimeLab\\s-\\s"];
                        
                        regextitle = [ez searchreplace:regextitle pattern:@"-\\sEpisode\\s"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\s.*"];
                        tmpepisode = [ez findMatch:regextitle pattern:@"(\\d\\d\\d|\\d\\d|\\d)" rangeatindex:0];
                        title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpseason = @"0"; //not supported
                    }
                    else
                        continue; // Invalid address
                }
                else if ([site isEqualToString:@"animenewsnetwork"]) {
                    if ([ez checkMatch:url pattern:@"video\\/[0-9]+"]) {
                        regextitle = [ez searchreplace:regextitle pattern:@"\\b\\s-\\sAnime News Network$"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\s\\((s|d)\\)\\s"];
                        regextitle = [ez searchreplace:regextitle pattern:@"ep\\."];
                        tmpepisode = [ez findMatch:regextitle pattern:@"(\\d\\d\\d|\\d\\d|\\d)" rangeatindex:0];
                        title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpseason = @"0"; //not supported
                    }
                    else
                        continue; // Invalid address
                }
                else if ([site isEqualToString:@"viz"]) {
                    if ([ez checkMatch:url pattern:@"anime\\/streaming\\/[^/]+-episode-[0-9]+\\/"]||[ez checkMatch:url pattern:@"anime\\/streaming\\/[^/]+-movie\\/"]) {
                        regextitle = [ez searchreplace:regextitle pattern:@"\\bVIZ.com - NEON ALLEY -\\s"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\s\\((DUB|SUB)\\)"];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\b\\sEpisode"];
                        tmpepisode = [ez findMatch:regextitle pattern:@"(\\d\\d\\d|\\d\\d|\\d)" rangeatindex:0];
                        title = [ez findMatch:regextitle pattern:@"\\b.*\\s" rangeatindex:0];
                        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        tmpseason = @"0"; //not supported
                    }
                    else
                        continue; // Invalid address
                }
				else if ([site isEqualToString:@"netflix"]){
					//Experimental
                    if([ez checkMatch:url pattern:@"WiPlayer"]){
						NSString * DOM = [NSString stringWithFormat:@"%@",[m objectForKey:@"DOM"]];
						DOM = [ez findMatch:DOM pattern:@"\"metadata\":\"*.*\",\"initParams\"" rangeatindex:0];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@"metadata:" withString:@""];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@",initParams" withString:@""];
						// Decode JSON Data
						NSData * jsonData = [[NSData alloc] initWithBase64Encoding:DOM];
					    NSError* error;
					    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
						NSDictionary *videodata = [metadata objectForKey:@"video"];
						title = [videodata objectForKey:@"title"];
						NSArray * seasondata = [videodata objectForKey:@"seasons"];
                        for (int i = 0; i < [seasondata count]; i++) {
                            NSDictionary * season = [seasondata objectAtIndex:i];
                            NSArray *episodes = [season objectForKey:@"episodes"];
                            for (int e = 0; e < [episodes count]; e++) {
                                NSDictionary * episode = [episodes objectAtIndex:e];
                                if ([episode objectForKey:@"bookmark"] !=nil) {
                                    continue;
                                }
                                else{
                                    tmpepisode = [NSString stringWithFormat:@"%@", [episode objectForKey:@"seq"]];
                                    break;
                                }
                            }
                        }
                        tmpseason = @"0"; //not supported
					}
					else
						continue;
				}
                else{
                    continue;
                }
                NSNumber * episode;
                NSNumber * season;
                // Final Checks
                if ([tmpepisode length] ==0){
                    episode = [NSNumber numberWithInt:0];
                }
                else{
                    episode = [[[NSNumberFormatter alloc] init] numberFromString:tmpepisode];
                }
                if (title.length == 0) {
                    continue;
                }
                season = [[[NSNumberFormatter alloc] init] numberFromString:tmpseason];
                // Add to Final Array
                NSDictionary * frecord = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", episode, @"episode", season, @"season", [m objectForKey:@"browser"], @"browser", site, @"site", nil];
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


