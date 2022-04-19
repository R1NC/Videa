//
//  BaseVC.h
//  Videa
//
//  Created by Rinc Liu on 18/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define runOnUIThread(block) dispatch_async(dispatch_get_main_queue(), block)

@interface BaseVC : UIViewController

- (void)didBecomeActive;

- (void)willResignActive;

- (void)didEnterBackground;

- (void)willEnterForeground;

- (void)keyboardDidShow:(CGRect)frame;

- (void)keyboardDidHide;

- (void)checkPhotoLibraryWithHandler:(void(^)(BOOL))handler;

- (void)checkCameraWithHandler:(void(^)(BOOL))handler;

- (void)checkRecordWithHandler:(void(^)(BOOL))handler;

@end

NS_ASSUME_NONNULL_END
