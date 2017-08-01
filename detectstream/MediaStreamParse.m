//
//  MediaStreamParse.m
//  detectstream
//
//  Created by 高町なのは on 2015/02/09.
//  Copyright (c) 2015年 Chikorita157's Anime Blog. All rights reserved.
//
//  This class parses the title if it's playing an episode.
//  It will find title, episode and season information.
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

#import "MediaStreamParse.h"
#import "ezregex.h"

@implementation MediaStreamParse
+ (NSArray *)parse:(NSArray *)pages {
     NSMutableArray * final = [[NSMutableArray alloc] init];
    ezregex * ez = [[ezregex alloc] init];
    //Perform Regex and sanitize
    if (pages.count > 0) {
        for (NSDictionary *m in pages) {
            NSString * regextitle = [NSString stringWithFormat:@"%@",m[@"title"]];
            NSString * url = [NSString stringWithFormat:@"%@", m[@"url"]];
            NSString * site = [NSString stringWithFormat:@"%@", m[@"site"]];
            NSString * title;
            NSString * tmpepisode;
            NSString * tmpseason;
            if ([site isEqualToString:@"crunchyroll"]) {
                //Add Regex Arguments Here
                if ([ez checkMatch:url pattern:@"\\/home\\/history"]) {
                    // Scrobble from viewing history
                    //Get the Document Object Model
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    NSArray *history = [self generateCrunchyrollHistoryQueue:DOM];
                    if (history.count > 0) {
                        NSDictionary *historyobject = history[0];
                        title = historyobject[@"title"];
                        tmpepisode = historyobject[@"episode"];
                    }
                    else {
                        continue;
                    }
                }
                else if ([ez checkMatch:url pattern:@"[^/]+\\/episode-[0-9]+.*-[0-9]+"]||[ez checkMatch:url pattern:@"[^/]+\\/.*-movie-[0-9]+"]||[ez checkMatch:url pattern:@"[^/]+\\/.*-\\d+"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@"Crunchyroll - Watch\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\sMovie\\s-\\sMovie"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"\\sEpisode (\\d+)" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@"\\sEpisode"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\s*.*"];
                    title = regextitle;
                    if ([ez checkMatch:title pattern:@"Crunchyroll"]) {
                        continue;
                    }
                }
                else
                    continue;
            }
            else if ([site isEqualToString:@"daisuki"]) {
                //Add Regex Arguments for daisuki.net
                // To be removed October 31, 2017
                if ([ez checkMatch:url pattern:@"^(?=.*\\banime\\b)(?=.*\\bwatch\\b).*"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\sDAISUKI\\b"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\D\\D\\s*.*\\s-"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b\\D([^\\n\\r]*)$" rangeatindex:0];
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
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
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
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"viz"]) {
                if ([ez checkMatch:url pattern:@"watch\\/streaming\\/[^/]+-episode-[0-9]+\\/"]||[ez checkMatch:url pattern:@"watch\\/streaming\\/[^/]+-movie\\/"]) {
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    regextitle = [ez searchreplace:regextitle pattern:@"#\\d+\\s*.*\\/\\/\\sVIZ"];
                    regextitle = [ez searchreplace:regextitle pattern:@"#\\d+\\s\\w+"];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\s" rangeatindex:0];
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"funimation"]) {
                if ([ez checkMatch:url pattern:@"shows\\/*.*\\/"]) {
                    //Get the Document Object Model
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    tmpepisode = [ez findMatch:[NSString stringWithFormat:@"%@", DOM] pattern:@"Episode\\s+\\d+" rangeatindex:0];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@"Episode\\s+"];
                    title = [ez findMatch:[NSString stringWithFormat:@"%@", DOM] pattern:@"<h2 class=\"show-headline video-title\"><a href=\"*.*\">*.*<\\/a>" rangeatindex:0];
                    title = [ez searchreplace:title pattern:@"<h2 class=\"show-headline video-title\"><a href=\"*.*\">"];
                    title = [title stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
                    title = [ez searchreplace:title pattern:@"\\s-\\s*.*"];
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"netflix"]){
                if([ez checkMatch:url pattern:@"WiPlayer"]){
                    //Get the Document Object Model
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    //Get the Episode Movie ID
                    NSArray * matches = [ez findMatches:url pattern:@"\\b(EpisodeMovieId|episodeId)=\\d+"];
                    NSString * videoid;
                    if (matches.count > 0) {
                        videoid = [NSString stringWithFormat:@"%@", [[ez findMatches:url pattern:@"\\b(EpisodeMovieId|episodeId)=\\d+"] lastObject]];
                        videoid = [ez searchreplace:videoid pattern:@"(EpisodeMovieId|episodeId)="];
                    }
                    NSData * jsonData;
                    if ([ez checkMatch:DOM pattern:@"\"video\":*.*\\]\\}\\}"]){
                        // HTML5 Player
                        if (videoid.length == 0) {
                            //Get Video ID
                            videoid = [ez findMatch:[NSString stringWithFormat:@"%@", m[@"DOM"]] pattern:@"\"videoId\":\\d+" rangeatindex:0];
                            videoid = [videoid stringByReplacingOccurrencesOfString:@"\"videoId\":" withString:@""];
                        }
                        DOM = [NSString stringWithFormat:@"{%@",[ez findMatch:DOM pattern:@"\"video\":*.*\\]\\}\\}" rangeatindex:0]];
                        jsonData = [DOM dataUsingEncoding:NSUTF8StringEncoding];
                    }
                    else{
                        if (videoid.length == 0) {
                            //Get Video ID
                            videoid = [ez findMatch:[NSString stringWithFormat:@"%@",m[@"DOM"]] pattern:@"EpisodeMovieId=\\d+" rangeatindex:0];
                            videoid = [videoid stringByReplacingOccurrencesOfString:@"EpisodeMovieId=" withString:@""];
                        }
                        // Silverlight Player
                        // Parse the DOM to get the JSON Data
                        DOM = [ez findMatch:DOM pattern:@"\"metadata\":\"*.*\",\"initParams\"" rangeatindex:0];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@"metadata:" withString:@""];
                        DOM = [DOM stringByReplacingOccurrencesOfString:@",initParams" withString:@""];
                        jsonData = [[NSData alloc] initWithBase64Encoding:DOM];
                    }
                    NSError* error;
                    // Parse JSON Data
                    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                    NSDictionary *videodata = metadata[@"video"];
                    // Set Title
                    title = videodata[@"title"];
                    // Search to get the right Episode Number
                    NSArray * seasondata = videodata[@"seasons"];
                    for (int i = 0; i < [seasondata count]; i++) {
                        NSDictionary * season = seasondata[i];
                        NSArray *episodes = season[@"episodes"];
                        for (int e = 0; e < [episodes count]; e++) {
                            NSDictionary * episode = episodes[e];
                            if (![videoid isEqualTo:[NSString stringWithFormat:@"%@", episode[@"id"]]]) {
                                continue;
                            }
                            else{
                                //Set Episode Number and Season
                                tmpepisode = [NSString stringWithFormat:@"%@", episode[@"seq"]];
                                tmpseason = [NSString stringWithFormat:@"%i", i+1];
                                break;
                            }
                        }
                    }
                }
                else
                    continue;
            }
            else if ([site isEqualToString:@"plex"]){
                if ([ez checkMatch:url pattern:@"web\\/app"]||[ez checkMatch:url pattern:@"web\\/index.html"]) {
                    // Check if there is a usable episode number
                    if (![regextitle isEqualToString:@"Plex"]) {
                        regextitle = [ez searchreplace:regextitle pattern:@"\\▶\\s"];
                        // Just return title, let Anitomy pharse the rest
                        title = regextitle;
                        tmpepisode = @"0";
                    }
                    else{
                        continue;
                    }
                }
                else{
                    continue;
                }
            }
            else if ([site isEqualToString:@"viewster"]) {
                if ([ez checkMatch:url pattern:@"\\/serie\\/\\d+-\\d+-\\d+\\/*.*\\/"]) {
                    //Get the Document Object Model
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    regextitle = [ez findMatch:DOM pattern:@".*\\sEpisode\\s\\d+:" rangeatindex:0];
                    tmpepisode = [ez findMatch:regextitle pattern:@"Episode\\s\\d+" rangeatindex:0];
                    title = [regextitle stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:",tmpepisode] withString:@""];
					tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"wakanim"]) {
                if ([ez checkMatch:url pattern:@"video(-premium)?/[^/]+/"]) {
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@" - Wakanim.TV" withString:@""];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@"de " withString:@""];
                    regextitle = [ez searchreplace:regextitle pattern:@"en\\sVOSTFR\\s\\/\\sStreaming"];
                    regextitle = [ez searchreplace:regextitle pattern:@"Episode\\s"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\s.*" rangeatindex:0];
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"myanimelist"]) {
                if ([ez checkMatch:url pattern:@"anime\\/\\d+\\/*.*\\/episode\\/\\d+"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"- MyAnimeList.net"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\sEpisode"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\D-\\s*.*$"];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"hidive"]) {
                //Add Regex Arguments for hidive
                if ([ez checkMatch:url pattern:@"(stream\\/*.*\\/s\\d+e\\d+|stream\\/*.*\\/\\d+)"]) {
                    if ([ez checkMatch:regextitle pattern:@"Episode \\d+"]) {
                        // Regular TV series
                        tmpseason = [ez findMatch:regextitle pattern:@"Season \\d+" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                        tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season " withString:@""];
                        tmpepisode = [ez findMatch:regextitle pattern:@"Episode \\d+" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
                        title = [regextitle stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    }
                    else {
                        // Movie or OVA
                        tmpepisode = @"1";
                        tmpseason = @"1";
                        title = [ez searchreplace:regextitle pattern:@" - (OVA|Movie|Special)"];
                    }
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"vrv"]) {
                //Add Regex Arguments Here
                if ([ez checkMatch:url pattern:@"\\/watch\\/*.*\\/*.*"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@"VRV - Watch\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\sMovie\\s-\\sMovie"];
                    tmpepisode = [ez findMatch:regextitle pattern:@":\\s(EP|Ep|ep) (\\d+)" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@":\\s(EP|Ep|ep) "];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\s*.*"];
                    title = regextitle;
                    if ([ez checkMatch:title pattern:@"VRV"]) {
                        continue;
                    }
                }
                else
                    continue;
            }
            else{
                continue;
            }
        
            NSNumber * episode;
            NSNumber * season;
            // Populate Season
            if (tmpseason.length == 0) {
                // Parse Season from title
                NSDictionary * seasondata = [MediaStreamParse checkSeason:title];
                if (seasondata != nil) {
                    season = (NSNumber *)seasondata[@"season"];
                    title = seasondata[@"title"];
                }
                else{
                   season = @(1);
                }
            }
            else{
                season = [[[NSNumberFormatter alloc] init] numberFromString:tmpseason];
            }
            //Trim Whitespace
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // Final Checks
            if ([tmpepisode length] ==0){
                episode = @(0);
            }
            else{
                episode = [[[NSNumberFormatter alloc] init] numberFromString:tmpepisode];
            }
            if (title.length == 0) {
                continue;
            }
            // Add to Final Array
            NSDictionary * frecord = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", episode, @"episode", season, @"season", [m objectForKey:@"browser"], @"browser", site, @"site", nil];
            [final addObject:frecord];
        }
    }
    return final;
}
+ (NSDictionary *)checkSeason:(NSString *) title {
    // Parses season
    ezregex * ez = [ezregex new];
    NSString * tmpseason;
    NSDictionary * result;
    NSString * pattern = @"(\\d(st|nd|rd|th) season|season \\d|s\\d)";
    if ([ez checkMatch:title pattern:pattern]) {
        tmpseason = [ez findMatch:title pattern:pattern rangeatindex:0];
        title = [title stringByReplacingOccurrencesOfString:tmpseason withString:@""];
        tmpseason = [ez findMatch:tmpseason pattern:@"\\d+" rangeatindex:0];
        result = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", [[NSNumberFormatter alloc] numberFromString:tmpseason], @"season", nil];
        
    }
    pattern = @"(first|season|third|fourth|fifth) season";
    if ([ez checkMatch:title pattern:@"(first|season|third|fourth|fifth) season"] && tmpseason.length == 0) {
        tmpseason = [ez findMatch:title pattern:pattern rangeatindex:0];
        title = [title stringByReplacingOccurrencesOfString:tmpseason withString:@""];
        result = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title",@([MediaStreamParse recognizeseason:tmpseason]), @"season", nil];
    }
    return result;
}
+ (int)recognizeseason:(NSString *)season {
    if ([season caseInsensitiveCompare:@"second season"] == NSOrderedSame) {
        return 2;
    }
    else if ([season caseInsensitiveCompare:@"third season"] == NSOrderedSame) {
        return 3;
    }
    else if ([season caseInsensitiveCompare:@"fourth season"] == NSOrderedSame) {
        return 4;
    }
    else if ([season caseInsensitiveCompare:@"fifth season"] == NSOrderedSame) {
        return 5;
    }
    else {
        return 1;
    }
}
+ (NSArray *)generateCrunchyrollHistoryQueue:(NSString *)DOM {
    // Creates an array of titles and episodes from Crunchyroll history
    ezregex *regex = [ezregex new];
    NSString *tmpdom = [DOM stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableArray *tmparray = [NSMutableArray new];
    NSArray *matches = [regex findMatches:tmpdom pattern:@"<li class=\"group-item hover-bubble\" id=\"media_group_\\d+\" group_id=\"media_group_\\d+\">(.*?)<\\/li>"];
    for (NSString *item in matches) {
        if ([regex checkMatch:item pattern:@"<span itemprop=\"name\" class=\"series-title block ellipsis\">(.*?)<\\/span>"]) {
            NSString *title = [regex findMatch:item pattern:@"<span itemprop=\"name\" class=\"series-title block ellipsis\">(.*?)<\\/span>" rangeatindex:0];
            title = [title stringByReplacingOccurrencesOfString:@"<span itemprop=\"name\" class=\"series-title block ellipsis\">" withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
            NSString *episode = @"1";
            if ([regex checkMatch:item pattern:@"Episode \\d+"]) {
                episode = [regex findMatch:item pattern:@"Episode \\d+" rangeatindex:0];
                episode = [episode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
            }
            [tmparray addObject:@{@"title":title, @"episode":episode}];
        }
        else {
            continue;
        }
    }
    return tmparray;
    
}
@end
