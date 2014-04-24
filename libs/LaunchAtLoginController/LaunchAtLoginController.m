//
//  LaunchAtLoginController.m
//  LaunchAtLoginController
//
//  Created by Katsuma Tanaka on 2014/04/12.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import "LaunchAtLoginController.h"

static NSString * const kStartAtLoginKey = @"launchAtLogin";

@interface LaunchAtLoginController ()

@end

@implementation LaunchAtLoginController

void sharedFileListDidChange(LSSharedFileListRef fileList, void *context)
{
    id obj = (__bridge id)context;
    [obj willChangeValueForKey:kStartAtLoginKey];
    [obj didChangeValueForKey:kStartAtLoginKey];
}

+ (instancetype)sharedController
{
    static id _sharedController = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        // Start observing
        LSSharedFileListAddObserver(_loginItems,
                                    CFRunLoopGetMain(),
                                    (CFStringRef)NSDefaultRunLoopMode,
                                    sharedFileListDidChange,
                                    (__bridge void *)(self));
    }
    
    return self;
}

- (void)dealloc
{
    // Stop observing
    LSSharedFileListRemoveObserver(_loginItems,
                                   CFRunLoopGetMain(),
                                   (CFStringRef)NSDefaultRunLoopMode,
                                   sharedFileListDidChange,
                                   (__bridge void *)(self));
    [super dealloc];
}


#pragma mark - Managing Login Item

- (LSSharedFileListItemRef)findItemWithURL:(NSURL *)itemURL inFileList:(LSSharedFileListRef)fileList
{
    if (itemURL == NULL || fileList == NULL) {
        return NULL;
    }
    
    NSArray *fileListSnapshot = (NSArray *)LSSharedFileListCopySnapshot(fileList, NULL);
    
    for (id itemObject in fileListSnapshot) {
        LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        LSSharedFileListItemResolve(item, resolutionFlags, &currentItemURL, NULL);
        
        if (currentItemURL && CFEqual(currentItemURL, (__bridge CFTypeRef)itemURL)) {
            CFRelease(currentItemURL);
            return item;
        }
        
        if (currentItemURL) {
            CFRelease(currentItemURL);
        }
    }
    
    return NULL;
}

- (BOOL)isLaunchAtLoginEnabled:(NSURL *)itemURL
{
    return ([self findItemWithURL:itemURL inFileList:_loginItems] != NULL);
}

- (void)setLaunchAtLoginEnabled:(BOOL)enabled forURL:(NSURL *)itemURL
{
    LSSharedFileListItemRef appItem = [self findItemWithURL:itemURL inFileList:_loginItems];
    
    if (enabled && !appItem) {
        LSSharedFileListInsertItemURL(_loginItems, kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
    } else if (!enabled && appItem) {
        LSSharedFileListItemRemove(_loginItems, appItem);
    }
}


#pragma mark - Basic Interface

- (NSURL *)mainApplicationURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void)setLaunchAtLoginEnabled:(BOOL)enabled
{
    [self willChangeValueForKey:kStartAtLoginKey];
    [self setLaunchAtLoginEnabled:enabled forURL:[self mainApplicationURL]];
    [self didChangeValueForKey:kStartAtLoginKey];
}

- (BOOL)isLaunchAtLoginEnabled
{
    return [self isLaunchAtLoginEnabled:[self mainApplicationURL]];
}

@end
