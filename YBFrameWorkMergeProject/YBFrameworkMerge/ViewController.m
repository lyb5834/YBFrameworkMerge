//
//  ViewController.m
//  YBFrameworkMerge
//
//  Created by LYB on 16/12/12.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import "ViewController.h"

#define YB_KEY_WINDOW [NSApplication sharedApplication].keyWindow

#define YB_ALERT_SHOW(text) NSAlert *alert = [[NSAlert alloc] init];\
alert.messageText = @"⚠️警告";\
alert.informativeText = (text);\
[alert beginSheetModalForWindow:YB_KEY_WINDOW completionHandler:nil];\

@implementation ViewController
{
    NSString * x86Path;
    NSString * arm64Path;
    NSString * outPutPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (IBAction)onMergeClick:(id)sender {
    
    if (![x86Path hasSuffix:@".framework"] && ![x86Path hasSuffix:@".a"]) {
        YB_ALERT_SHOW(@"这不是合法的framework或者.a文件！！");
        return;
    }
    
    if (![arm64Path hasSuffix:@".framework"] && ![arm64Path hasSuffix:@".a"]) {
        YB_ALERT_SHOW(@"这不是合法的framework或者.a文件！！");
        return;
    }
    
    if (![[x86Path lastPathComponent] isEqualToString:[arm64Path lastPathComponent]]) {
        YB_ALERT_SHOW(@"sdk名称不一致！！！");
        return;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:@"选择需要合并后的路径"];
    [panel setPrompt:@"OK"];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseFiles:NO];
    NSString *path_all;
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton)
    {
        path_all = [[panel URL] path];
        NSLog(@"合并后的路径：%@",path_all);
        outPutPath = path_all;
        [self createSDK];
    }
}

- (void)createSDK
{
    NSString *commandStr;
    if ([arm64Path hasSuffix:@".a"]) {
        commandStr = [NSString stringWithFormat:@"lipo -create %@ %@ -output %@",arm64Path,x86Path,[outPutPath stringByAppendingPathComponent:[arm64Path lastPathComponent]]];
        int s = system([commandStr UTF8String]);
        if (s == 0) {
            YB_ALERT_SHOW(@"合并成功！！！！");
        }
    }else {
        NSString *frameworkName = [self getFrameworkNameWithPath:arm64Path];
        commandStr = [NSString stringWithFormat:@"lipo -create %@ %@ -output %@",[arm64Path stringByAppendingPathComponent:frameworkName],[x86Path stringByAppendingPathComponent:frameworkName],[outPutPath stringByAppendingPathComponent:frameworkName]];
        int s = system([commandStr UTF8String]);
        if (s == 0) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error = nil;
            NSString *copyFrameworkPath = [outPutPath stringByAppendingPathComponent:[arm64Path lastPathComponent]];
            if ([fileManager fileExistsAtPath:copyFrameworkPath]) {
                [fileManager removeItemAtPath:copyFrameworkPath error:&error];
            }
            [fileManager copyItemAtPath:arm64Path toPath:copyFrameworkPath error:&error];
            if (error) {
                YB_ALERT_SHOW(error.localizedDescription);
            }else {
                [fileManager removeItemAtPath:[copyFrameworkPath stringByAppendingPathComponent:frameworkName] error:&error];
                [fileManager moveItemAtPath:[outPutPath stringByAppendingPathComponent:frameworkName] toPath:[copyFrameworkPath stringByAppendingPathComponent:frameworkName] error:&error];
                if (error) {
                    YB_ALERT_SHOW(error.localizedDescription);
                }else {
                    YB_ALERT_SHOW(@"合并成功！！！！");
                }
            }
        }
    }
}

- (NSString *)getFrameworkNameWithPath:(NSString *)path
{
    NSString *frameworkName;
    NSString *searchStr = @".framework";
    if ([path hasSuffix:searchStr]) {
        frameworkName = [[path lastPathComponent] substringToIndex:[path lastPathComponent].length - searchStr.length];
    }
    return frameworkName;
}


/***
 第五步：实现dragdropview的代理函数，如果有数据返回就会触发这个函数
 ***/
-(void)dragDropViewFileList:(NSArray *)fileList dragDropView:(DragDropView *)dragDropView
{
    //如果数组不存在或为空直接返回不做处理（这种方法应该被广泛的使用，在进行数据处理前应该现判断是否为空。）
    if(!fileList || [fileList count] <= 0)return;
    //在这里我们将遍历这个数字，输出所有的链接，在后台你将会看到所有接受到的文件地址
    for (int n = 0 ; n < [fileList count] ; n++) {
        
        if (dragDropView == _x86DropView) {
            x86Path = [fileList objectAtIndex:n];
            if (![x86Path hasSuffix:@".framework"] && ![x86Path hasSuffix:@".a"]) {
                _x86Label.stringValue = @"'framework' or '.a' please";
                [dragDropView setDragDropEvent:DragDropEvent_Failed];
            }else {
                _x86Label.stringValue = [x86Path lastPathComponent];
                [dragDropView setDragDropEvent:DragDropEvent_Successd];
            }
            NSLog(@"模拟器sdk路径>>> %@",x86Path);
        }else if (dragDropView == _arm64DropView) {
            arm64Path = [fileList objectAtIndex:n];
            if (![arm64Path hasSuffix:@".framework"] && ![arm64Path hasSuffix:@".a"]) {
                _arm64Label.stringValue = @"'framework' or '.a' please";
                [dragDropView setDragDropEvent:DragDropEvent_Failed];
            }else {
                _arm64Label.stringValue = [arm64Path lastPathComponent];
                [dragDropView setDragDropEvent:DragDropEvent_Successd];
            }
            NSLog(@"真机sdk路径>>> %@",arm64Path);
        }
    }
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
