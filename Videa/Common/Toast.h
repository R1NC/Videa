//
//  Toast.h
//  Videa
//
//  Created by R1NC on 27/07/2017.
//  Copyright © 2017 Rinc Liu. All rights reserved.
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
