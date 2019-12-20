//
//  Irvue+hook.m
//  IrvuePlugin
//
//  Created by 大笨刘 on 2019/12/18.
//  Copyright © 2019 mac. All rights reserved.
//

#import "Irvue+hook.h"

#import <AppKit/AppKit.h>

#import <objc/runtime.h>

#import "fishhook.h"

@implementation NSObject (IrvueHook)

+ (void)hookIrvue {
    //      获取更新时间间隔
    Method originalMethod = class_getInstanceMethod(objc_getClass("LPWallpaperManager"), NSSelectorFromString(@"updateInterval"));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(hook_updateInterval));
    if(originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    //      替换沙盒路径
    rebind_symbols((struct rebinding[2]) {
        { "NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *)&original_NSSearchPathForDirectoriesInDomains },
        { "NSHomeDirectory", swizzled_NSHomeDirectory, (void *)&original_NSHomeDirectory }
    }, 2);
}

- (double)hook_updateInterval {
    NSLog(@"=== Custom update interval for Irvue ===");
    return 300.0;
}

#pragma mark - 替换 NSSearchPathForDirectoriesInDomains & NSHomeDirectory
static NSArray<NSString *> *(*original_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

NSArray<NSString *> *swizzled_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde) {
    NSMutableArray<NSString *> *paths = [original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde) mutableCopy];
    NSString *sandBoxPath = [NSString stringWithFormat:@"%@/Library/Containers/com.leonspok.osx.Irvue/Data",original_NSHomeDirectory()];
    
    [paths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [filePath rangeOfString:original_NSHomeDirectory()];
        if (range.length > 0) {
            NSMutableString *newFilePath = [filePath mutableCopy];
            [newFilePath replaceCharactersInRange:range withString:sandBoxPath];
            paths[idx] = newFilePath;
        }
    }];
    
    return paths;
}

static NSString *(*original_NSHomeDirectory)(void);

NSString *swizzled_NSHomeDirectory(void) {
    return [NSString stringWithFormat:@"%@com.leonspok.osx.Irvue/Data",original_NSHomeDirectory()];
}


@end
