//
//  Toast.h
//  DingDang
//
//  Created by RincLiu on 27/07/2017.
//  Copyright © 2017 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Toast : UIView

+(instancetype)shared;

-(void)showText:(NSString*)text duration:(NSTimeInterval)duration block:(void(^)(void))block;

-(void)showText:(NSString*)text block:(void(^)(void))block;

-(void)showText:(NSString*)text duration:(NSTimeInterval)duration;

-(void)showText:(NSString*)text;

- (void)remove;

@end
