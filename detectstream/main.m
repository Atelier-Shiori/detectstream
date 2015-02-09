//
//  main.m
//  detectstream
//
//  Created by 高町なのは on 2014/10/21.
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
// Do not want to output timestamp for the output

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#import <Foundation/Foundation.h>
// Support Classes
#import "BrowserDetection.h"
#import "MediaStreamParse.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //  Get Pages
        NSArray * pages = [BrowserDetection getPages];
        // Parse page titles
        NSArray * final = [MediaStreamParse parse:pages];
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
            // Output JSON
            NSLog(@"%@", JSONString);
        }
    }
    return 0;
}


