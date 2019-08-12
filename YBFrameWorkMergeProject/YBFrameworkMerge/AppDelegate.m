//
//  AppDelegate.m
//  YBFrameworkMerge
//
//  Created by LYB on 16/12/12.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag){
        //主窗口显示
        for (NSWindow * window in sender.windows) {
            [window makeKeyAndOrderFront:self];
        }
    }
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
