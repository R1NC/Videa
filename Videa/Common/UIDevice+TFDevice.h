//
//  UIDevice+TFDevice.h
//  DingDang
//
//  Created by fredyfang(方义) on 2018/9/4.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (TFDevice)
/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end
