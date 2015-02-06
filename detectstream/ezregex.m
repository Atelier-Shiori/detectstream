//
//  ezregex.h
//  Detectstream
//
//  Created by Tail Red on 2/06/15.
//  Copyright 2015 Atelier Shiori. All rights reserved. Code licensed under New BSD License
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

#import "ezregex.h"

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
-(NSArray *)findMatches:(NSString *)string pattern:(NSString *)pattern {
    NSError *errRegex = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&errRegex];
    NSRange  searchrange = NSMakeRange(0, [string length]);
    NSArray * a = [regex matchesInString:string options:kNilOptions range:searchrange];
    NSMutableArray * results = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult * result in a ) {
        [results addObject:[string substringWithRange:[result rangeAtIndex:0]]];
    }
    return results;
}
@end