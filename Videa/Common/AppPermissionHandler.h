//
//  AppPermissionHandler.h
//  DingDang
//
//  Created by Rinc Liu on 6/9/2019.
//  Copyright © 2019 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppPermissionHandler : NSObject

+(void)checkPhotoLibraryWithHandler:(void(^)(BOOL))handler;

@end

NS_ASSUME_NONNULL_END
