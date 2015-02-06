//
//  browsercheck.m
//  detectstream
//
//  Created by 高町なのは on 2015/02/06.
//  Copyright (c) 2014, Atelier Shiori and James M.
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

#import "browsercheck.h"

@implementation browsercheck
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
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(crunchyroll|daisuki|animelab|animenewsnetwork|viz|netflix|plex|32400)" //Supported Streaming Sites
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    NSString * teststring = url;
    NSRange  searchrange = NSMakeRange(0, [teststring length]);
        NSTextCheckingResult *match = [regex firstMatchInString:teststring options:0 range: searchrange];
        NSRange matchRange = [regex rangeOfFirstMatchInString:teststring options:NSMatchingReportProgress range:searchrange];
    NSString * result;
        if (matchRange.location != NSNotFound) {
            result = [teststring substringWithRange:[match rangeAtIndex:1]];
            if ([result isEqualToString:@"32400"]) {
                //Plex local port, return plex
                return @"plex";
            }
            return result;
        }
        else{
            return result;
        }
    
}
@end
