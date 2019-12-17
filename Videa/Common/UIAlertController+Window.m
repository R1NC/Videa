//
//  UIAlertController+Window.m
//  DingDang
//
//  Created by RincLiu on 31/07/2017.
//  Copyright © 2017 tencent. All rights reserved.
//

#import "UIAlertController+Window.h"
#import <objc/runtime.h>
#import "UIDevice+TFDevice.h"

@interface UIAlertController (Private)

@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign) BOOL landScape;
@end

@implementation UIAlertController (Private)

@dynamic alertWindow;
@dynamic landScape;

- (void)setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

- (void)setLandScape:(BOOL)landScape {
    objc_setAssociatedObject(self, @selector(landScape), [NSNumber numberWithBool:landScape], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)landScape {
    return [objc_getAssociatedObject(self, @selector(landScape)) boolValue];
}
@end

@implementation UIAlertController (Window)

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    NSLog(@"UIAlertController (Window) supportedInterfaceOrientations self.landScape:%d", self.landScape);
    if (self.landScape) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    NSLog(@"UIAlertController (Window) preferredInterfaceOrientationForPresentation self.landScape:%d", self.landScape);
    if (self.landScape) {
        return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
}

- (void)show {
    [self show:YES withLandOrientation:NO];
}

- (void)show:(BOOL)animated withLandOrientation:(BOOL)landscape{
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    self.landScape = landscape;
    /*id<UIApplicationDelegate> delegate = [AppDelegate get];
    // Applications that does not load with UIMainStoryboardFile might not have a window property:
    if ([delegate respondsToSelector:@selector(window)]) {
        // we inherit the main window's tintColor
        self.alertWindow.tintColor = delegate.window.tintColor;
    }*/
    // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"UIAlertController (Window) viewWillAppear self.landScape:%d", self.landScape);
    if (self.landScape) {
        [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
    } else {
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"UIAlertController (Window) viewDidDisappear...");
    // precaution to insure window gets destroyed
    [self.alertWindow resignKeyWindow];
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

@end
