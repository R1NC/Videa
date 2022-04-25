//
//  UIUtil.m
//  Videa
//
//  Created by R1NC on 07/07/2017.
//  Copyright © 2017 Rinc Liu. All rights reserved.
//

#import "UIUtil.h"

static NSTimeInterval lastClick;

@implementation UIUtil

+(CGFloat)measureLabelWidth:(UILabel*)label MaxWidth:(CGFloat)maxWidth {
    NSDictionary *atrr = @{NSFontAttributeName : label.font};
    CGSize size = [(label.text ? label.text : @"") boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:atrr
                                                      context:nil].size;
    return size.width;
}

+(UILabel*)LabelFromFrame:(CGRect)frame Color:(UIColor*)color Size:(CGFloat)size {
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setTextColor:color];
    [label setFont:[UIFont systemFontOfSize:size]];
    return label;
}

+(void)setNormalAttrStr:(NSMutableAttributedString*)attrStr color:(UIColor*)color size:(CGFloat)size start:(NSInteger)start length:(NSInteger)length {
    [self setAttrStr:attrStr color:color font:[UIFont systemFontOfSize:size] start:start length:length];
}

+(void)setBoldAttrStr:(NSMutableAttributedString*)attrStr color:(UIColor*)color size:(CGFloat)size start:(NSInteger)start length:(NSInteger)length {
    [self setAttrStr:attrStr color:color font:[UIFont boldSystemFontOfSize:size] start:start length:length];
}

+(void)setItalicAttrStr:(NSMutableAttributedString*)attrStr color:(UIColor*)color size:(CGFloat)size start:(NSInteger)start length:(NSInteger)length {
    [self setAttrStr:attrStr color:color font:[UIFont italicSystemFontOfSize:size] start:start length:length];
}

+(void)setAttrStr:(NSMutableAttributedString*)attrStr color:(UIColor*)color font:(UIFont*)font start:(NSInteger)start length:(NSInteger)length {
    NSRange range = NSMakeRange(start, length);
    [attrStr addAttribute:NSFontAttributeName value:font range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName value:color range:range];
}

+(void)setLabel:(UILabel*)label wordSpace:(float)wordSpace lineSpace:(float)lineSpace {
    if (label && label.text && label.text.length > 0) {
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:label.text attributes:@{NSKernAttributeName:[NSNumber numberWithFloat:wordSpace]}];
        NSMutableParagraphStyle* paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineSpacing:lineSpace];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label.text length])];
        [label setAttributedText:attributedString];
        [label sizeToFit];
        label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
}

+(UIImage*)imageFromColor:(UIColor*)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(void)addShadowToView:(UIView*)v bgColor:(UIColor*)bgColor cornerRadius:(float)radius {
    if (bgColor) v.backgroundColor = bgColor;
    v.layer.masksToBounds = NO;
    v.layer.shadowColor = [UIColor blackColor].CGColor;
    v.layer.shadowOffset = CGSizeMake(0, 2);
    v.layer.shadowOpacity = 0.12f;
    v.layer.shadowRadius = 2;
    v.layer.cornerRadius = radius;
}

+(UIVisualEffectView*)blurViewWithFrame:(CGRect)frame {
    UIVisualEffectView* blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.frame = frame;
    return blurEffectView;
}

+(BOOL)checkClick {
    NSTimeInterval t = [[NSDate date]timeIntervalSince1970];
    if (lastClick == 0.0f || t - lastClick > 1.0f || t < lastClick) {
        lastClick = t;
        return YES;
    }
    return NO;
}

+(void)textView:(UITextView *)tv appendLine:(NSString *)line {
    NSString* txt = tv.text ? tv.text : @"";
    tv.text = [txt stringByAppendingFormat:@"\n%@", line];
    [self.class scrollTextViewToBottom:tv];
}

+ (void)scrollTextViewToBottom:(UITextView*)tv {
    if (!tv.text) return;
    [tv scrollRangeToVisible:NSMakeRange(tv.text.length -1, 1)];
}

@end
