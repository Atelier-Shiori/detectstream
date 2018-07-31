//
//  DetectStreamManager.m
//  DetectStream
//
//  Created by 天々座理世 on 2018/07/30.
//  Copyright © 2018 Chikorita157's Anime Blog. All rights reserved.
//

#import "DetectStreamManager.h"
#import <DetectStreamKit/BrowserDetection.h>
#import <DetectStreamKit/MediaStreamParse.h>

@implementation DetectStreamManager
- (NSDictionary *)detectStream {
    NSDictionary *finalresult;
    @autoreleasepool {
        //  Get Pages
        NSArray * pages = [BrowserDetection getPages];
        // Parse page titles
        NSArray * final = [MediaStreamParse parse:pages];
        // Generate Final Dictionary Output
        NSDictionary * result;
        if (final.count > 0 ) {
            result = @{@"result": final};
        }
        else {
            // Empty final array, send null
            result = @{@"result": [NSNull null]};
        }
        finalresult = result.copy;
    }
    return finalresult;
}
@end
