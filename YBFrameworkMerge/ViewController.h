//
//  ViewController.h
//  YBFrameworkMerge
//
//  Created by LYB on 16/12/12.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragDropView.h"

@interface ViewController : NSViewController
<DragDropViewDelegate>

@property (weak) IBOutlet NSTextField *x86Label;

@property (weak) IBOutlet NSTextField *arm64Label;

@property (weak) IBOutlet DragDropView *x86DropView;

@property (weak) IBOutlet DragDropView *arm64DropView;


@end

