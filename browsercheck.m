//
//  browsercheck.m
//  detectstream
//
//  Created by 高町なのは on 2014/10/22.
//  Copyright (c) 2014年 Chikorita157's Anime Blog. All rights reserved.
//

#import "browsercheck.h"

@implementation browsercheck
-(BOOL)checkSafari {
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSArray *runningApps = [ws runningApplications];
    NSDictionary *d;
    for (d in runningApps ) {
        if ([[d valueForKey: @"NSApplicationBundleIdentifier"] isEqualToString:@"com.apple.safari"]) {
            return true;
        }
    }
    return false;
    
}
@end
