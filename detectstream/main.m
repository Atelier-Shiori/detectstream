//
//  main.m
//  detectstream
//
//  Created by 高町なのは on 2014/10/21.
//  Copyright 2014-2020 Atelier Shiori, James Moy. All rights reserved. Code licensed under MIT License.
//
// Do not want to output timestamp for the output

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#import <Foundation/Foundation.h>
// Support Classes
#import <DetectStreamKit/BrowserDetection.h>
#import <DetectStreamKit/MediaStreamParse.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //  Get Pages
        NSArray * pages = [BrowserDetection getPages];
        // Parse page titles
        NSArray * final = [MediaStreamParse parse:pages];
        // Generate JSON and output
        NSDictionary * result;
        if (final.count > 0 ) {
            result = @{@"result": final};
        }
        else {
            // Empty final array, send null
            result = @{@"result": [NSNull null]};
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


