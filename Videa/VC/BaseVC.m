//
//  BaseVC.m
//  Videa
//
//  Created by Rinc Liu on 18/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "BaseVC.h"
#import "UIUtil.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "SystemSettings.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveN:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveN:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundN:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundN:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowN:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideN:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowN:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideN:) name:UIKeyboardDidHideNotification object:nil];
    SetTapCallback(self.view, @selector(onTapRoot));
}

-(void)onTapRoot {
    [self.view endEditing:YES];
}

-(void)viewDidDisappearN:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)didBecomeActiveN:(NSNotification *)notification {
    [self didBecomeActive];
}

- (void)willResignActiveN:(NSNotification *)notification {
    [self willResignActive];
}

- (void)didEnterBackgroundN:(NSNotification *)notification {
    [self didEnterBackground];
}

- (void)willEnterForegroundN:(NSNotification *)notification {
    [self willEnterForeground];
}

- (void)keyboardWillShowN:(NSNotification *)notification {
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [self.view convertRect:[value CGRectValue] fromView:nil];
    [self keyboardWillShow:keyboardFrame];
}

- (void)keyboardWillHideN:(NSNotification *)notification {
    [self keyboardWillHide];
}

- (void)keyboardDidShowN:(NSNotification *)notification {
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [self.view convertRect:[value CGRectValue] fromView:nil];
    [self keyboardDidShow:keyboardFrame];
}

- (void)keyboardDidHideN:(NSNotification *)notification {
    [self keyboardDidHide];
}

- (void)didBecomeActive {}

- (void)willResignActive {}

- (void)didEnterBackground {}

- (void)willEnterForeground {}

- (void)keyboardWillShow:(CGRect)frame {}

- (void)keyboardWillHide {}

- (void)keyboardDidShow:(CGRect)frame {}

- (void)keyboardDidHide {}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)callHandler:(void(^)(BOOL))handler result:(BOOL)result {
    if (handler) {
        runOnUIThread(^{
            handler(result);
        });
    }
}

-(void)checkPhotoLibraryWithHandler:(void(^)(BOOL))handler {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self callHandler:handler result:YES];
    } else if (status == PHAuthorizationStatusDenied) {
        [self alertWithPermission:@"相册" handler:handler];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self callHandler:handler result:status == PHAuthorizationStatusAuthorized];
        }];
    }
}

-(void)checkCameraWithHandler:(void(^)(BOOL))handler {
    [self checkCapturePermissionWithType:AVMediaTypeVideo handler:handler];
}

-(void)checkRecordWithHandler:(void(^)(BOOL))handler {
    [self checkCapturePermissionWithType:AVMediaTypeAudio handler:handler];
}

-(void)checkCapturePermissionWithType:(AVMediaType)type handler:(void(^)(BOOL))handler {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:type];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [self callHandler:handler result:YES];
    } else if (authStatus == AVAuthorizationStatusDenied) {
        NSString* p = type == AVMediaTypeAudio ? @"麦克风" : @"相机";
        [self alertWithPermission:p handler:handler];
    } else {
        [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {
            if (granted) {
                [self callHandler:handler result:YES];
            } else {
                NSString* p = type == AVMediaTypeAudio ? @"麦克风" : @"相机";
                [self alertWithPermission:p handler:handler];
            }
        }];
    }
}

-(void)alertWithPermission:(NSString*)permission handler:(void(^)(BOOL))handler {
    runOnUIThread((^{
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"无%@访问权限", permission] message:@"请前往设置开启" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [SystemSettings myApp:^(BOOL success) {
                [self callHandler:handler result:NO];
            }];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self callHandler:handler result:NO];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }));
}

@end
