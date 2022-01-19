//
//  UIUtil.h
//  Videa
//
//  Created by R1NC on 07/07/2017.
//  Copyright © 2017 Rinc Liu. All rights reserved.
//

#ifndef ViewUtil_h
#define ViewUtil_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define Image(img) [UIImage imageNamed:img]

#define SetImage(v,img) [v setImage:Image(img)]

#define Storyboard(s) [UIStoryboard storyboardWithName:s bundle:nil]
#define StoryboardVCI(s) [Storyboard(s) instantiateInitialViewController]
#define StoryboardVC(s,vc) [Storyboard(s) instantiateViewControllerWithIdentifier:vc]

#define SetTitleColorNormal(v,color) [v setTitleColor:color forState:UIControlStateNormal]

#define SetTitleColorDisabled(v,color) [v setTitleColor:color forState:UIControlStateDisabled]

#define SetTitleColorHighlighted(v,color) [v setTitleColor:color forState:UIControlStateHighlighted]

#define SetTitleNormal(v,title) [v setTitle:title forState:UIControlStateNormal]

#define SetTitleDisabled(v,title) [v setTitle:title forState:UIControlStateDisabled]

#define SetImageNormal(v,img) [v setImage:Image(img) forState:UIControlStateNormal]

#define SetImageHighlighted(v,img) [v setImage:Image(img) forState:UIControlStateHighlighted]

#define SetImageDisabled(v,img) [v setImage:Image(img) forState:UIControlStateDisabled]

#define SetLabelTextSize(l,s) [l setFont:[UIFont systemFontOfSize:s]]

#define SetButtonTextSize(l,s) [l.titleLabel setFont:[UIFont systemFontOfSize:s]]

#define SetClickCallbackT(v,sel,t) do {\
[v addTarget:t action:sel forControlEvents:UIControlEventTouchUpInside];\
v.exclusiveTouch = YES;\
} while (0)

#define SetClickCallback(v,sel) SetClickCallbackT(v,sel,self)

#define SetTapCallbackT(v,sel,t) do {\
v.userInteractionEnabled = YES;\
[v addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:t action:sel]];\
v.exclusiveTouch = YES;\
} while (0)

#define SetTapCallback(v,sel) SetTapCallbackT(v,sel,self)

#define NibView(n,i) [[NSBundle mainBundle] loadNibNamed:n owner:self options:nil][i]

#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define iPhoneX ((kSCREEN_WIDTH == 375.f && kSCREEN_HEIGHT == 812.f) || (kSCREEN_WIDTH == 414.f && kSCREEN_HEIGHT == 896.f))

#define iPhoneX_Landscape ((kSCREEN_WIDTH == 812.f && kSCREEN_HEIGHT == 375.f) || (kSCREEN_WIDTH == 896.f && kSCREEN_HEIGHT == 414.f))

#define iPhoneX_BOTTOM_SPACE 34

#define BOTTOM_SPACE (iPhoneX ? iPhoneX_BOTTOM_SPACE : 0)

#define kSTATUS_BAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height

#define kNAVIGATION_BAR_HEIGHT self.navigationController.navigationBar.frame.size.height

#define UIColorFromARGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)((rgbValue & 0xFF000000) >> 24))/255.0]

@interface UIUtil : NSObject

+(CGFloat)measureLabelWidth:(UILabel*)label MaxWidth:(CGFloat)maxWidth;

+(UILabel*)LabelFromFrame:(CGRect)frame Color:(UIColor*)color Size:(CGFloat)size;

+(void)setNormalAttrStr:(NSMutableAttributedString*)attrStr color:(UIColor*)color size:(CGFloat)size start:(NSInteger)start length:(NSInteger)length;

+(void)setBoldAttrStr:(NSMutableAttributedString*)attrStr color:(UIColor*)color size:(CGFloat)size start:(NSInteger)start length:(NSInteger)length;

+(void)setItalicAttrStr:(NSMutableAttributedString*)attrStr color:(UIColor*)color size:(CGFloat)size start:(NSInteger)start length:(NSInteger)length;

+(void)setLabel:(UILabel*)label wordSpace:(float)wordSpace lineSpace:(float)lineSpace;

+(UIImage*)imageFromColor:(UIColor*)color;

+(void)addShadowToView:(UIView*)v bgColor:(UIColor*)bgColor cornerRadius:(float)radius;

+(UIVisualEffectView*)blurViewWithFrame:(CGRect)fram;

+(BOOL)checkClick;

+(void)textView:(UITextView*)tv appendLine:(NSString*)line;

@end

#endif /* UIUtil_h */
