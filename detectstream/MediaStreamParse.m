//
//  MediaStreamParse.m
//  detectstream
//
//  Created by 高町なのは on 2015/02/09.
//  Copyright 2014-2020 Atelier Shiori, James Moy. All rights reserved. Code licensed under MIT License.
//

#import "MediaStreamParse.h"
#import "ezregex.h"
#import "NSString+HTML.h"

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
            NSString * title = @"";
            NSString * tmpepisode = @"";
            NSString * tmpseason = @"";
            bool isManga = false;
            if ([site isEqualToString:@"crunchyroll"]) {
                    if ([ez checkMatch:url pattern:@"\\/watch\\/.+\\/.+"]) {
                        // Crunchyroll Beta Watch Page
                        // Requires Javascript Scraping
                        NSString *DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                        NSString *metastring = [ez findMatch:DOM pattern:@"E\\d+ - .+<\\/h1>" rangeatindex:0];
                        metastring = [metastring stringByReplacingOccurrencesOfString:@"</h1>" withString:@""];
                        tmpepisode = [ez findMatch:DOM pattern:@"E\\d+ -" rangeatindex:0];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@" -" withString:@""];
                    
                        NSString *tmpeptitle = [ez findMatch:DOM pattern:@"<h1 class=\".+\">.(.*?)<\\/h1>" rangeatindex:0];
                        tmpeptitle = [ez searchreplace:tmpeptitle pattern:@"<h1 class=\".+\">"];
                        tmpeptitle = [tmpeptitle stringByReplacingOccurrencesOfString:@"</h1>" withString:@""];
                        tmpeptitle = [ez searchreplace:tmpeptitle pattern:@"E\\d+ - "];
                        tmpeptitle = [tmpeptitle stringByReplacingOccurrencesOfString:@"- " withString:@""];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:@" - Watch on Crunchyroll" withString:@""];
                        if ([ez findMatches:regextitle pattern:tmpeptitle].count > 0) {
                            NSRange origEpTitle = [regextitle rangeOfString:tmpeptitle];
                            if (NSNotFound != origEpTitle.location) {
                            regextitle = [regextitle stringByReplacingCharactersInRange:origEpTitle withString:@""];
                            }
                        }
                        title = regextitle;
                    }
                    else if ([url containsString:@"history"]) {
                        // Crunchyroll Beta History Page
                        // Requires Javascript Scraping
                        NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                        NSArray *history = [self generateBetaCrunchyrollHistoryQueue:DOM];
                        if (history.count > 0) {
                            NSDictionary *historyobject = history[0];
                            title = historyobject[@"title"];
                            tmpepisode = historyobject[@"episode"];
                            tmpseason = historyobject[@"season"];
                        }
                        else {
                            continue;
                        }
                    }
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
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"animenewsnetwork"]) {
                if ([ez checkMatch:url pattern:@"video\\/[0-9]+"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"\\b\\s-\\sAnime News Network$"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s\\((s|d)\\)\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"ep\\."];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"viz"]) {
                if ([ez checkMatch:url pattern:@"watch\\/streaming\\/[^/]+-episode-[0-9]+\\/"]||[ez checkMatch:url pattern:@"watch\\/streaming\\/[^/]+-movie\\/"]) {
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    regextitle = [ez searchreplace:regextitle pattern:@"#\\d+\\s*.*\\/\\/\\sVIZ"];
                    regextitle = [ez searchreplace:regextitle pattern:@"#\\d+\\s\\w+"];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\s" rangeatindex:0];
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"funimation"]) {
                if ([ez checkMatch:url pattern:@"shows\\/.*\\/.*\\/.*"]) {
	                regextitle = [regextitle stringByReplacingOccurrencesOfString:@"Watch " withString:@""];
	                regextitle = [ez findMatch:regextitle pattern:@".* Season \\d+ Episode \\d+" rangeatindex:0];
	                tmpepisode = [ez findMatch:regextitle pattern:@"Episode \\d+" rangeatindex:0];
	                tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
	                tmpseason = [ez findMatch:regextitle pattern:@"Season \\d+" rangeatindex:0];
	                tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season "  withString:@""];
	                title = [ez searchreplace:regextitle pattern:@"Season \\d+ Episode \\d+"];
                }
                else if ([ez checkMatch:url pattern:@"v\\/.*\\/.*"]) {
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    regextitle = [ez findMatch:DOM pattern:@".* \\|" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@" |" withString:@""];
                    tmpepisode = [ez findMatch:DOM pattern:@"Episode\\n\\s+\\d+" rangeatindex:0];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@"Episode\\n\\s+"];
                    tmpseason = [ez findMatch:DOM pattern:@"Season\\n\\s+\\d+" rangeatindex:0];
                    tmpseason = [ez searchreplace:tmpseason pattern:@"Season\\n\\s+"];
                    title = regextitle;
                }
                else if ([url.lowercaseString containsString:@"/account/"]) {
	                NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
	                regextitle = [ez findMatch:DOM pattern:@"<a href=\"\\/shows\\/.*\\/.*\\/?qid=\">.*<\\/a>" rangeatindex:0];
					regextitle = [ez searchreplace:regextitle pattern:@"<a href=\"\\/shows\\/.*\\/.*\\/?qid=\">"];
					regextitle = [ez searchreplace:regextitle pattern:@"<\\/a>"];
					tmpepisode = [ez findMatch:DOM pattern:@"Episode \\d+" rangeatindex:0];
					tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
					tmpseason = [ez findMatch:DOM pattern:@"Season \\d+" rangeatindex:0];
					tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season "  withString:@""];
					title = regextitle;
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"netflix"]){
                if([ez checkMatch:url pattern:@"\\/watch\\/\\d+"]){
                   NSString *DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                   NSError *error;
                   NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:[DOM dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                   if (error) {
                       continue;
                   }
                   else {
                        regextitle = metadata[@"title"];
                        tmpepisode = ((NSNumber *)metadata[@"episode"]).stringValue;
                        tmpseason = ((NSNumber *)(NSNumber *)metadata[@"season"]).stringValue;
                        title = regextitle;   
                   }
                }
                else {
                    continue;
                }
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
                    else {
                        continue;
                    }
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"youtube"]){
                if ([ez checkMatch:url pattern:@"\\/watch\\?v="]) {
                    // Check if there is a usable episode number
                        regextitle = [ez searchreplace:regextitle pattern:@" - YouTube"];
                        // Just return title, let Anitomy pharse the rest
                        title = regextitle;
                        tmpepisode = @"0";
                }
                else {
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
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"wakanim"]) {
                if ([ez checkMatch:url pattern:@"/[^/]+/v2/catalogue/episode/[^/]+/"]) {
                    NSArray *matches = [ez findMatches:regextitle pattern:@"(?:Episode (\\d+)|Film|Movie) - (?:ENGDUB - )?(.+)"];
                    if (matches.count > 2) {
                      regextitle = matches[1];
                      tmpepisode = matches[0];
                    }
                    else {
                      regextitle = matches[0];
                    }
                    title = regextitle;
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"myanimelist"]) {
                if ([ez checkMatch:url pattern:@"anime\\/\\d+\\/*.*\\/episode\\/\\d+"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"- MyAnimeList.net"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\sEpisode"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"(\\d+)" rangeatindex:0];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\D-\\s*.*$"];
                    title = [ez findMatch:regextitle pattern:@"\\b.*\\D" rangeatindex:0];
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"hidive"]) {
                //Add Regex Arguments for hidive
                if ([ez checkMatch:url pattern:@"(stream\\/*.*\\/s\\d+e\\d+|stream\\/*.*\\/\\d+)"]) {
                    // Clean title
                    regextitle = [ez searchreplace:regextitle pattern:@"(Stream | on HIDIVE)"];
                    if ([ez checkMatch:regextitle pattern:@"Episode \\d+"]) {
                        // Regular TV series
                        tmpseason = [ez findMatch:regextitle pattern:@"Season \\d+" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                        tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season " withString:@""];
                        tmpepisode = [ez findMatch:regextitle pattern:@"Episode \\d+ of" rangeatindex:0];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@" of" withString:@""];
                        title = [regextitle stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    }
                    else {
                        // Movie or OVA
                        tmpepisode = @"1";
                        tmpseason = @"1";
                        title = [ez searchreplace:regextitle pattern:@" - (OVA|Movie|Special)"];
                    }
                }
                else {
                    continue; // Invalid address
                }
            }
            else if ([site isEqualToString:@"vrv"]) {
                //Add Regex Arguments Here
                if ([ez checkMatch:url pattern:@"\\/watch\\/*.*\\/*.*"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@" - Watch on VRV\\s"];
                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\sMovie\\s-\\sMovie"];
                    tmpepisode = [ez findMatch:regextitle pattern:@"\\s(Episode) (\\d+)" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@"\\s(Episode) "];
                    tmpseason  = [ez findMatch:regextitle pattern:@"Season (\\d+)" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                    tmpseason  = [ez searchreplace:tmpseason pattern:@"Season "];                    regextitle = [ez searchreplace:regextitle pattern:@"\\s-\\s*.*"];
                    title = regextitle;
                    if ([ez checkMatch:title pattern:@"VRV"]) {
                        continue;
                    }
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"amazon"]) {
                // Amazon Prime Video/Anime Strike
                if ([ez checkMatch:url pattern:@"(\\/gp\\/video\\/detail\\/*.*|\\/.+\\/dp\\/.*|\\/gp\\/product\\/.*?pf_rd_p=)"]) {
                    NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    if ([DOM isEqualToString:@"(null) - (null)"]) {
                        // Silverlight Player not supported
                        continue;
                    }
                    regextitle = [ez findMatch:DOM pattern:@".* - " rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@" - " withString:@""];
                    tmpepisode = [ez findMatch:DOM pattern:@"(Ep.|Episode|E) \\d+" rangeatindex:0];
                    tmpepisode = [ez searchreplace:tmpepisode pattern:@"(Ep.|Episode|E) "];
                    if ([ez checkMatch:DOM  pattern:@"Season \\d+"]) {
                        regextitle = [NSString stringWithFormat:@"%@ %@",regextitle, [ez findMatch:DOM pattern:@"Season \\d+" rangeatindex:0]];
                    }
                    title = regextitle;
                }
            }
            else if ([site isEqualToString:@"tubitv"]) {
                //Add Regex Arguments Here
                if ([ez checkMatch:url pattern:@"\\/*.+\\/\\d+\\/s\\d+_e\\d+"]) {
                    //Perform Sanitation
                    regextitle = [ez searchreplace:regextitle pattern:@"(Watch | - *.* \\| Tubi)"];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:@":" withString:@" "];
                    tmpseason = [ez findMatch:regextitle pattern:@"S\\d+" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                    tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
                    tmpepisode = [ez findMatch:regextitle pattern:@"E\\d+" rangeatindex:0];
                    regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                    tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                    title = regextitle;
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"asiancrush"]) {
                if ([ez checkMatch:url pattern:@"(\\/video\\/*.+\\/\\d+v|\\/video\\/\\d+v)"]) {
                    regextitle = [ez searchreplace:regextitle pattern:@"(Subbed|Dubbed)"];
                    if ([ez checkMatch:regextitle pattern:@".* S\\d+E\\d+"]) {
                        regextitle = [ez findMatch:regextitle pattern:@".* S\\d+E\\d+" rangeatindex:0];
                        regextitle = [ez searchreplace:regextitle pattern:@"\\(.*\\)"];
                        tmpseason = [ez findMatch:regextitle pattern:@"S\\d+" rangeatindex:0];
                        tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
                        tmpepisode = [ez findMatch:regextitle pattern:@"E\\d+" rangeatindex:0];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                        title = [ez searchreplace:regextitle pattern:@"S\\d+E\\d+"];
                    }
                    else {
                        regextitle = [ez searchreplace:regextitle pattern:@"(Subbed|Dubbed)"];
                        regextitle = [regextitle stringByReplacingOccurrencesOfString:@" | Watch Full Movie Free | AsianCrush" withString:@""];
                        title = regextitle;
                    }
                }
                else {
                   continue;
                }
            }
            else if ([site isEqualToString:@"animedigitalnetwork"]) {
                if ([ez checkMatch:url pattern:@"\\/video\\/.*\\/\\d+"]) {
                       regextitle = [ez searchreplace:regextitle pattern:@" - streaming -.* ADN"];
                       if ([ez checkMatch:regextitle pattern:@".*-.*\\d+"]) {
                          regextitle = [ez findMatch:regextitle pattern:@".*-.*\\d+" rangeatindex:0];
                          tmpepisode = [ez findMatch:regextitle pattern:@" -.*\\d+" rangeatindex:0];
                          regextitle = [ez searchreplace:regextitle pattern:@" -.*\\d+"];
                          tmpepisode = [ez findMatch:tmpepisode pattern:@"\\d+" rangeatindex:0];
                       }
                       title = regextitle;
                }
                else {
                      continue;
                }
            }
            else if ([site isEqualToString:@"sonycrackle"]) {
                      if ([ez checkMatch:regextitle pattern:@"Watch *.+ Online Free - Sony Crackle"]) {
                      regextitle = [ez searchreplace:regextitle pattern:@"(Watch |Online Free - Sony Crackle)"];
                      if ([ez findMatch:regextitle pattern:@", Episode \\d+" rangeatindex:0]) {
                                tmpepisode = [ez findMatch:regextitle pattern:@", Episode \\d+" rangeatindex:0];
                                regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpepisode withString:@""];
                                tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@", Episode " withString:@""];
                      }
                      if ([ez findMatch:regextitle pattern:@", Season \\d+" rangeatindex:0]) {
                                tmpseason = [ez findMatch:regextitle pattern:@", Season \\d+" rangeatindex:0];
                                regextitle = [regextitle stringByReplacingOccurrencesOfString:tmpseason withString:@""];
                                tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@", Season " withString:@""];
                      }
                      title = regextitle;
            }
            else {
                     continue;
            }
            }
            else if ([site isEqualToString:@"adultswim"]) {
                 if ([ez checkMatch:url pattern:@"\\/videos\\/*.+\\/*.+\\/"]) {
                      NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                      // Parse title
                      regextitle = [regextitle stringByReplacingOccurrencesOfString:@" - Adult Swim Shows" withString:@""];
                      regextitle = [ez searchreplace:regextitle pattern:@".+ - "];
                      NSArray *seasons = [ez findMatches:DOM pattern:@"<div class=\"season__root show-content__season\">*.+<\\/div>"];
                      if (seasons.count > 0) {
                           for (NSString *season in seasons) {
                                  // Get Temp Season
                                  tmpseason = [ez findMatch:season pattern:@"Season \\d+" rangeatindex:0];
                                  tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season " withString:@""];
                                  NSString *currentepisodedomregex = @"<div class=\"episode__root episode__selected\">*.+Ep \\d+";
                                  if ([ez checkMatch:DOM pattern:currentepisodedomregex]) {
                                        NSString *epdom = [ez findMatch:DOM pattern:currentepisodedomregex rangeatindex:0];
                                        tmpepisode = [ez findMatch:epdom pattern:@"Ep \\d+" rangeatindex:0];
                                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Ep " withString:@""];
                                        title = regextitle;
                                  }
                                  else {
                                        continue;
                                  }
                           }
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
				if ([ez checkMatch:url pattern:@"https:\\/\\/play.hbomax.com\\/(episode|feature)\\/urn\\:hbo\\:(episode|feature):"]) {
					NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
					if ([url containsString:@"episode"]) {
						NSString *titlepattern = @"<span style=\"font-family: street2_bold; font-size: 12px; font-style: normal; text-decoration: none; text-transform: uppercase; line-height: 18px; letter-spacing: 0px; color: rgb\\(255, 255, 255\\);\">.*<\\/span><\\/span><\\/div><\\/a><div class=\"default\" style=\"width\\: 313px; top\\: (3[3-9]|4[0-9]|5[01])px;\">";
						if ([ez checkMatch:DOM pattern:titlepattern]) {
							regextitle = [ez findMatch:DOM pattern:titlepattern rangeatindex:0];
							regextitle = [ez searchreplace:regextitle pattern:@"<span style=\"font-family: street2_bold; font-size: 12px; font-style: normal; text-decoration: none; text-transform: uppercase; line-height: 18px; letter-spacing: 0px; color: rgb\\(255, 255, 255\\);\">"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"<\\/span><\\/span><\\/div><\\/a><div class=\"default\" style=\"width\\: 313px; top\\: (3[3-9]|4[0-9]|5[01])px;\">"];
							tmpepisode = [ez findMatch:DOM pattern:@"Ep \\d+" rangeatindex:0];
							tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Ep " withString:@""];
							tmpseason = [ez findMatch:DOM pattern:@"Sn \\d+" rangeatindex:0];
							tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Sn " withString:@""];
							title = regextitle;
						}
						else {
							continue;
						}
					}
					else if ([url containsString:@"feature"]) {
                    NSString *titlepattern = @"<span style=\"font-family: street2_medium; font-size: 28px; font-style: normal; text-decoration: none; text-transform: none; line-height: 36px; letter-spacing: 0px; color: rgb\\(240, 240, 240\\);\">.*<\\/span><\\/span><\\/div><div class=\"default\" style=\"width: 313px; top: (5[1-9]|[6-9][0-9]|1[01][0-9]|12[0-3])px;\">";
						if ([ez checkMatch:DOM pattern:titlepattern]) {
							regextitle = [ez findMatch:DOM pattern:titlepattern rangeatindex:0];
							regextitle = [ez searchreplace:regextitle pattern:@"<span style=\"font-family: street2_medium; font-size: 28px; font-style: normal; text-decoration: none; text-transform: none; line-height: 36px; letter-spacing: 0px; color: rgb\\(240, 240, 240\\);\">"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"<\\/span><\\/span><\\/div><div class=\"default\" style=\"width: 313px; top: (5[1-9]|[6-9][0-9]|1[01][0-9]|12[0-3])px;\">"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"((G|PG-13|PG|R|TV-14|NC-17) \\| (2.0|Stereo|5.1) \\| (HD|SD).*|(G|PG-13|PG|R|TV-14|NC-17) \\| (HD|SD).*)"];
                        	regextitle = [ez searchreplace:regextitle pattern:@"<span style=\"*.*\">"];
							tmpepisode = @"1";
							tmpseason = @"1";
							title = regextitle;
						}
						else {
							continue;
						}
					}
				}
            }
            else if ([site isEqualToString:@"retrocrush"]) {
            	if ([ez checkMatch:url pattern:@"\\/video\\/.*\\/\\d+.*"]) {
            		NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
            		regextitle = [ez findMatch:DOM pattern:@"<a href=\"\\/series\\/.*\">.*<\\/a>" rangeatindex:0];
            		regextitle = [ez searchreplace:regextitle pattern:@"<a href=\"\\/series\\/.*\">"];
            		regextitle = [regextitle stringByReplacingOccurrencesOfString:@"</a>" withString:@""];
            		tmpepisode = [ez findMatch:DOM pattern:@"Episode \\d+" rangeatindex:0];
            		tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"Episode " withString:@""];
            		tmpseason = [ez findMatch:DOM pattern:@"Season \\d+" rangeatindex:0];
            		tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"Season " withString:@""];
            		title = regextitle;
            	}
			}
            else if ([site isEqualToString:@"hulu"]) {
	            if ([ez checkMatch:url pattern:@"\\/watch\\/.*"]) {
		            if (m[@"DOM"]) {
			            NSString * DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
			            regextitle = [ez findMatch:DOM pattern:@"<div class=\"ClampedText\" *.+><span>.*<\\/span>" rangeatindex:0];
			            regextitle = [ez searchreplace:regextitle pattern:@"<div class=\"ClampedText\" *.+><span>"];
			            regextitle = [regextitle stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
			            tmpepisode = [ez findMatch:DOM pattern:@"E\\d+" rangeatindex:0];
			            tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
			            tmpseason = [ez findMatch:DOM pattern:@"S\\d+" rangeatindex:0];
			            tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
			            title = regextitle;
		            }
	            }
            }
            else if ([site isEqualToString:@"peacocktv"]){
                if ([ez checkMatch:url pattern:@"\\/watch\\/playback\\/"]) {
                    NSString *DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    NSError *error;
                    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:[DOM dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    if (error) {
                        continue;
                    }
                    else {
                        regextitle = metadata[@"title"];
                        tmpepisode = metadata[@"episode"];
                        tmpseason = [ez findMatch:tmpepisode pattern:@"S\\d+" rangeatindex:0];
                        tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
                        tmpepisode = [ez findMatch:tmpepisode pattern:@"E\\d+" rangeatindex:0];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                        title = regextitle;
                    }
                }
                else {
                    continue;
                }
            }
            else if ([site isEqualToString:@"disneyplus"]) {
                if ([ez checkMatch:url pattern:@"\\/video\\/.+"]) {
                    NSString *DOM = [NSString stringWithFormat:@"%@",m[@"DOM"]];
                    NSError *error;
                    NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:[DOM dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                    if (error) {
                        continue;
                    }
                    else {
                        regextitle = metadata[@"title"];
                        tmpepisode = metadata[@"meta"];
                        tmpseason = [ez findMatch:tmpepisode pattern:@"S\\d+" rangeatindex:0];
                        tmpseason = [tmpseason stringByReplacingOccurrencesOfString:@"S" withString:@""];
                        tmpepisode = [ez findMatch:tmpepisode pattern:@"E\\d+" rangeatindex:0];
                        tmpepisode = [tmpepisode stringByReplacingOccurrencesOfString:@"E" withString:@""];
                        title = regextitle;
                    }
                }
                else {
                    continue;
                }
            }
            else {
                continue;
            }
        
            NSNumber * episode;
            NSNumber * season;
            // Populate Season
            if (tmpseason.length == 0 && !isManga) {
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
            else {
                season = [[[NSNumberFormatter alloc] init] numberFromString:tmpseason];
            }
            //Trim Whitespace
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            tmpepisode = [tmpepisode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // Decode HTML
            title = [title kv_decodeHTMLCharacterEntities];
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
            NSDictionary * frecord;
            if (!isManga) {
                frecord = @{@"title" :title, @"episode" : episode, @"season" : season, @"browser" : m[@"browser"], @"site" : site, @"type" : @"anime" };
            }
            else {
                 frecord = @{@"title" :title, @"chapter" : episode, @"browser" : m[@"browser"], @"site" : site, @"type" : @"manga" };
            }
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
    NSString * pattern = @"(\\d+(st|nd|rd|th) season|season \\d+|s\\d+|season\\d+)";
    if ([ez checkMatch:title pattern:pattern]) {
        tmpseason = [ez findMatch:title pattern:pattern rangeatindex:0];
        title = [title stringByReplacingOccurrencesOfString:tmpseason withString:@""];
        tmpseason = [ez findMatch:tmpseason pattern:@"\\d+" rangeatindex:0];
        result = @{@"title": title, @"season": [[NSNumberFormatter alloc] numberFromString:tmpseason]};
        
    }
    pattern = @"(first|season|third|fourth|fifth) season";
    if ([ez checkMatch:title pattern:@"(first|season|third|fourth|fifth) season"] && tmpseason.length == 0) {
        tmpseason = [ez findMatch:title pattern:pattern rangeatindex:0];
        title = [title stringByReplacingOccurrencesOfString:tmpseason withString:@""];
        result = @{@"title": title, @"season": @([MediaStreamParse recognizeseason:tmpseason])};
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
+ (NSArray *)generateBetaCrunchyrollHistoryQueue:(NSString *)DOM {
    // Creates an array of titles and episodes from Crunchyroll history (Beta)
    ezregex *regex = [ezregex new];
    NSString *tmpdom = [DOM stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableArray *tmparray = [NSMutableArray new];
    NSArray *matches = [regex findMatches:tmpdom pattern:@"<div class=\"erc-my-lists-item\">(.*?)<\\/button>"];
    for (NSString *item in matches) {
        if ([regex checkMatch:item pattern:@"<small class=\"(.*?)<\\/small>"]) {
            NSString *title = [regex findMatch:item pattern:@"<small class=\"(.*?)<\\/small>" rangeatindex:0];
            title = [regex searchreplace:title pattern:@"<small class=\"(.*?)\">"];
            title = [title stringByReplacingOccurrencesOfString:@"</small>" withString:@""];
            NSString *episode = @"1";
            NSString *season = @"1";
            if ([regex checkMatch:item pattern:@"E\\d+"]) {
                episode = [regex findMatch:item pattern:@"E\\d+" rangeatindex:0];
                episode = [episode stringByReplacingOccurrencesOfString:@"E" withString:@""];
            }
            if ([regex checkMatch:item pattern:@"S\\d+"]) {
                season = [regex findMatch:item pattern:@"S\\d+" rangeatindex:0];
                season = [season stringByReplacingOccurrencesOfString:@"S" withString:@""];
            }
            [tmparray addObject:@{@"title":title, @"episode":episode, @"season":season}];
        }
        else {
            continue;
        }
    }
    return tmparray;
    
}
@end
