//
//  AppPermissionHandler.m
//  DingDang
//
//  Created by Rinc Liu on 6/9/2019.
//  Copyright © 2019 tencent. All rights reserved.
//

#import "AppPermissionHandler.h"
#import <Photos/Photos.h>
#import "UIAlertController+Window.h"
#import "SystemSettings.h"

@implementation AppPermissionHandler

+(void)callHandler:(void(^)(BOOL))handler result:(BOOL)result {
    if (handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(result);
        });
    }
}

+(void)checkPhotoLibraryWithHandler:(void(^)(BOOL))handler {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self callHandler:handler result:YES];
    } else if (status == PHAuthorizationStatusDenied) {
        [self alertWithPermission:@"相册" landscape:NO handler:handler];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self callHandler:handler result:status == PHAuthorizationStatusAuthorized];
        }];
    }
}

+(void)alertWithPermission:(NSString*)permission landscape:(BOOL)landscape handler:(void(^)(BOOL))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"\"Videa\"无%@访问权限", permission] message:@"请前往设置开启" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [SystemSettings myApp];
            [self callHandler:handler result:NO];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self callHandler:handler result:NO];
        }]];
        [alertController show:YES withLandOrientation:landscape];
    });
}

@end
