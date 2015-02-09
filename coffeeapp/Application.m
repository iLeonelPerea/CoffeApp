//
//  Application.m
//  coffeeapp
//
//  Created by Omar Guzmán on 2/9/15.
//  Copyright (c) 2015 crowdint. All rights reserved.
//

#import "Application.h"

@implementation Application

- (BOOL)openURL:(NSURL*)url {
    
    if ([[url absoluteString] hasPrefix:@"googlechrome-x-callback:"]) {
        
        return NO;
        
    } else if ([[url absoluteString] hasPrefix:@"https://accounts.google.com/o/oauth2/auth"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationOpenGoogleAuthNotification object:url];
        return NO;
        
    }
    
    return [super openURL:url];
}

@end
