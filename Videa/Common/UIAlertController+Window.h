//
//  UIAlertController+Window.h
//  DingDang
//
//  Created by RincLiu on 31/07/2017.
//  Copyright © 2017 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController(Window)

- (void)show;

- (void)show:(BOOL)animated withLandOrientation:(BOOL)landscape;

@end
