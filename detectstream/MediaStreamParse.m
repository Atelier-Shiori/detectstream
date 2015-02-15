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
+(NSArray *)parse:(NSArray *)pages{
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
                if ([ez checkMatch:url pattern:@"\\b[^/]+\\/episode-[0-9]+.*-[0-9]+$"]||[ez checkMatch:url pattern:@"\\b[^/]+\\/.*-movie-[0-9]+$"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@"Crunchyroll - Watch\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\sMovie\\s-\\sMovie"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\sEpisode"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\D-\\s*.*$"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
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
                if ([ez checkMatch:url pattern:@"anime\\/streaming\\/[^/]+-episode-[0-9]+\\/"]||[ez checkMatch:url pattern:@"anime\\/streaming\\/[^/]+-movie\\/"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"\\bVIZ.com - NEON ALLEY -\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s\\((DUB|SUB)\\)"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\b\\sEpisode"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\s" rangeatindex:0];
                }
                else
                    continue; // Invalid address
            }
            else if ([site isEqualToString:@"netflix"]){
                if([ez checkMatch:url pattern:@"WiPlayer"]){
                    //Get the Document Object Model
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    //Get the Episode Movie ID
                    NSArray * matches = [ez findMatches:url pattern:@"\\b(EpisodeMovieId)=\\d+"];
                    NSString * videoid;
                    if (matches.count > 0) {
                        videoid = [NSString stringWithFormat:@"%@", [[ez findMatches:url pattern:@"\\b(EpisodeMovieId)=\\d+"] lastObject]];
                        videoid = [ez searchreplace:videoid pattern:@"(EpisodeMovieId)="];
                    }
                    else{
                        videoid = [ez findMatch:[NSString stringWithFormat:@"%@",m[@"DOM"]] pattern:@"EpisodeMovieId=\\d+" rangeatindex:0];
                        videoid = [videoid stringByReplacingOccurrencesOfString:@"EpisodeMovieId=" withString:@""];
                    }
                    // Parse the DOM to get the JSON Data
                    DOM = [ez findMatch:DOM pattern:@"\"metadata\":\"*.*\",\"initParams\"" rangeatindex:0];
                    DOM = [DOM stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    DOM = [DOM stringByReplacingOccurrencesOfString:@"metadata:" withString:@""];
                    DOM = [DOM stringByReplacingOccurrencesOfString:@",initParams" withString:@""];
                    // Decode JSON Data
                    NSData * jsonData = [[NSData alloc] initWithBase64Encoding:DOM];
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
                        NSDictionary * seasoninfo = [MediaStreamParse checkSeason:regextitle];
                        if (seasoninfo) {
                            regextitle = seasoninfo[@"title"];
                            tmpseason = [(NSNumber *)seasoninfo[@"season"] stringValue];
                        }
                        tmpepisode = [ez findMatch:regextitle pattern:@"((ep|e)\\d+|episode \\d+|\\d+)" rangeatindex:0];
                        if (tmpepisode.length == 0){
                            // Probably a movie
                            tmpepisode = @"0";
                        }
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                        tmpepisode = [ez searchreplace:tmpepisode pattern:@"(ep|e|episode)"];
                        title = regextitle;
                    }
                    else{
                        continue;
                    }
                }
                else{
                    continue;
                }
            }
            else if ([site isEqualToString:@"animesols"]) {
                if ([ez checkMatch:url pattern:@"videos\\/\\d+"]) {
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@"Anime Sols " withString:@""];
                    regextitle = [ez searchreplace:regextitle pattern:@"-\\sEpisode\\s"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\s" rangeatindex:0];
                }
                else
                    continue; // Invalid address
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
+(NSDictionary *)checkSeason:(NSString *) title{
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
+(int)recognizeseason:(NSString *)season{
    if ([season caseInsensitiveCompare:@"second season"] == NSOrderedSame)
        return 2;
    else if ([season caseInsensitiveCompare:@"third season"] == NSOrderedSame)
        return 3;
    else if ([season caseInsensitiveCompare:@"fourth season"] == NSOrderedSame)
        return 4;
    else if ([season caseInsensitiveCompare:@"fifth season"] == NSOrderedSame)
        return 5;
    else
        return 1;
}
@end
