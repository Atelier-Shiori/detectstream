//
//  main.m
//  detectstream
//
//  Created by 高町なのは on 2014/10/21.
//  Copyright (c) 2014年 Chikorita157's Anime Blog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/SBApplication.h>
#import "Safari.h"

@import ScriptingBridge;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        SafariApplication* safari = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
        
        SBElementArray* documents = [safari documents];
        NSMutableArray* pages = [[NSMutableArray alloc]init];
        for (int i = 0; i<= [documents count]; i++) {

            SafariDocument* frontDocument = [documents objectAtIndex: i];
            id title = [safari doJavaScript: @"document.title" in: (SafariTab *) frontDocument];
            id url = [safari doJavaScript: @"document.URL" in: (SafariTab *) frontDocument];
            NSDictionary * page = [[NSDictionary alloc] initWithObjectsAndKeys:title,@"title",url, @"url",  nil];
            NSLog(@"%@", page);
            [pages addObject:page];
        }
        NSLog(@"%@", pages);
        
    }
    return 0;
}
