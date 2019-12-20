//
//  main.mm
//  Irvue
//
//  Created by 大笨刘 on 2019/12/19.
//  Copyright © 2019 Irvue. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Irvue+Hook.h"

static void __attribute__((constructor)) initialize(void) {
    NSLog(@"++++++++ IrvuePlugin loaded ++++++++");
    [NSObject hookIrvue];
}
