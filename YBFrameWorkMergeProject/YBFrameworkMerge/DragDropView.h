//
//  DragDropView.h
//  YBFrameworkMerge
//
//  Created by LYB on 16/12/12.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, DragDropEvent) {
    DragDropEvent_Normal = 0,
    DragDropEvent_Draging,
    DragDropEvent_Successd,
    DragDropEvent_Failed
};

@protocol DragDropViewDelegate;

IB_DESIGNABLE
@interface DragDropView : NSView
@property (assign) IBOutlet id<DragDropViewDelegate> delegate;
@property (assign) DragDropEvent dragDropEvent;
@end

@protocol DragDropViewDelegate <NSObject>
@optional
-(void)dragDropViewFileList:(NSArray*)fileList dragDropView:(DragDropView *)dragDropView;
-(void)touchdragDropView:(DragDropView *)dragDropView;
@end
