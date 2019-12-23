//
//  BaseVC.h
//  Videa
//
//  Created by Rinc Liu on 18/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseVC : UIViewController

- (void)didBecomeActive;

- (void)willResignActive;

- (void)didEnterBackground;

- (void)willEnterForeground;

- (void)keyboardDidShow:(CGRect)frame;

- (void)keyboardDidHide;

@end

NS_ASSUME_NONNULL_END
