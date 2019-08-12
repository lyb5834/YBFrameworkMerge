//
//  DragDropView.m
//  YBFrameworkMerge
//
//  Created by LYB on 16/12/12.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import "DragDropView.h"
#import <Quartz/Quartz.h>

@implementation DragDropView
@synthesize delegate = _delegate;
@synthesize dragDropEvent = _dragDropEvent;

- (void)dealloc {
    [self setDelegate:nil];
}

- (void)initialize
{
    /***
     第一步：帮助view注册拖动事件的监听器，可以监听多种数据类型，这里只列出比较常用的：
     NSStringPboardType         字符串类型
     NSFilenamesPboardType      文件
     NSURLPboardType            url链接
     NSPDFPboardType            pdf文件
     NSHTMLPboardType           html文件
     ***/
    //这里我们只添加对文件进行监听，如果拖动其他数据类型到view中是不会被接受的
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self setNeedsDisplay:YES];
    _dragDropEvent = DragDropEvent_Normal;
    [self setWantsLayer:YES];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)setDragDropEvent:(DragDropEvent)dragDropEvent
{
    _dragDropEvent = dragDropEvent;
    [self setNeedsDisplay:YES];
    if (dragDropEvent == DragDropEvent_Successd || dragDropEvent == DragDropEvent_Failed) {
        
        [self.layer addAnimation:[self getAnimation] forKey:@"dragDropAnimationKey"];
    }
}

- (DragDropEvent)dragDropEvent
{
    return _dragDropEvent;
}

- (CAAnimation *)getAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = @[@(0.1),@(0.4),@(1.0)];
    animation.keyTimes = @[@(0.1),@(0.4),@(0.9)];
    animation.removedOnCompletion = NO;
    animation.duration = 1.0;
    animation.repeatCount = 1;
    return animation;
}

/***
 第二步：当拖动数据进入view时会触发这个函数，我们可以在这个函数里面判断数据是什么类型，来确定要显示什么样的图标。比如接受到的数据是我们想要的NSFilenamesPboardType文件类型，我们就可以在鼠标的下方显示一个“＋”号，当然我们需要返回这个类型NSDragOperationCopy。如果接受到的文件不是我们想要的数据格式，可以返回NSDragOperationNone;这个时候拖动的图标不会有任何改变。
 ***/
-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
	NSPasteboard *pboard = [sender draggingPasteboard];
    
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        [self setDragDropEvent:DragDropEvent_Draging];
        return NSDragOperationCopy;
	}
    
	return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        [self setDragDropEvent:DragDropEvent_Normal];
    }
}

/***
 第三步：当在view中松开鼠标键时会触发以下函数，我们可以在这个函数里面处理接受到的数据
 ***/
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    // 1）、获取拖动数据中的粘贴板
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // 2）、从粘贴板中提取我们想要的NSFilenamesPboardType数据，这里获取到的是一个文件链接的数组，里面保存的是所有拖动进来的文件地址，如果你只想处理一个文件，那么只需要从数组中提取一个路径就可以了。
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    [self setDragDropEvent:DragDropEvent_Normal];
    // 3）、将接受到的文件链接数组通过代理传送
    if(self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewFileList: dragDropView:)])
        [self.delegate dragDropViewFileList:list dragDropView:self];
    return YES;
}

- (void)touchesBeganWithEvent:(NSEvent *)event
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchdragDropView:)]) {
        [self.delegate touchdragDropView:self];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [super drawRect:dirtyRect];
    
    if (_dragDropEvent == DragDropEvent_Draging) {
        [[NSColor lightGrayColor] setFill];
    }else {
        [[NSColor whiteColor] setFill];
    }
    NSRectFill(dirtyRect);
    
    if (_dragDropEvent == DragDropEvent_Normal || _dragDropEvent == DragDropEvent_Draging) {
        
        NSBezierPath *bezierPath = [NSBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        bezierPath.lineCapStyle = kCGLineCapRound;
        [bezierPath moveToPoint:NSMakePoint(30, dirtyRect.size.height / 2)];
        [bezierPath lineToPoint:NSMakePoint(dirtyRect.size.width - 30 , dirtyRect.size.height / 2)];
        [bezierPath moveToPoint:NSMakePoint(dirtyRect.size.height / 2, 30)];
        [bezierPath lineToPoint:NSMakePoint(dirtyRect.size.height / 2, dirtyRect.size.height - 30)];
        [bezierPath setLineWidth:5];
        [[NSColor orangeColor] setStroke];
        [bezierPath stroke];
        [NSBezierPath strokeRect:dirtyRect];
    }else if (_dragDropEvent == DragDropEvent_Successd) {
        
        NSBezierPath *bezierPath = [NSBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineCapRound;
        [bezierPath moveToPoint:NSMakePoint(30, dirtyRect.size.height / 2)];
        [bezierPath lineToPoint:NSMakePoint(30 + 20 , 30 )];
        [bezierPath lineToPoint:NSMakePoint(dirtyRect.size.width - 30, dirtyRect.size.height - 30)];
        [bezierPath setLineWidth:10];
        [[NSColor colorWithRed:0.27 green:0.98 blue:0.40 alpha:1.0] setStroke];
        [bezierPath stroke];
        [NSBezierPath strokeRect:dirtyRect];
    }else {
        
        NSBezierPath *bezierPath = [NSBezierPath bezierPath];
        bezierPath.lineJoinStyle = kCGLineCapRound;
        [bezierPath moveToPoint:NSMakePoint(30, 30)];
        [bezierPath lineToPoint:NSMakePoint(dirtyRect.size.width - 30 , dirtyRect.size.height - 30)];
        [bezierPath moveToPoint:NSMakePoint(dirtyRect.size.height - 30, 30)];
        [bezierPath lineToPoint:NSMakePoint(30, dirtyRect.size.height - 30)];
        [bezierPath setLineWidth:10];
        [[NSColor redColor] setStroke];
        [bezierPath stroke];
        [NSBezierPath strokeRect:dirtyRect];
    }
}

@end
