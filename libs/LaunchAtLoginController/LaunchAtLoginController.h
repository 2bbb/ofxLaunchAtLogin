//
//  LaunchAtLoginController.h
//  LaunchAtLoginController
//
//  Created by Katsuma Tanaka on 2014/04/12.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaunchAtLoginController : NSObject {
    LSSharedFileListRef _loginItems;
}

+ (instancetype)sharedController;

- (BOOL)isLaunchAtLoginEnabled:(NSURL *)itemURL;
- (void)setLaunchAtLoginEnabled:(BOOL)enabled forURL:(NSURL *)itemURL;

- (void)setLaunchAtLoginEnabled:(BOOL)enabled;
- (BOOL)isLaunchAtLoginEnabled;

@end
