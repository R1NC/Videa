//
//  Toast.m
//  Videa
//
//  Created by R1NC on 27/07/2017.
//  Copyright © 2017 Rinc Liu. All rights reserved.
//

#import "Toast.h"
#import "UIUtil.h"

#define ALPHA 0.97531
#define DURATION 2

static Toast *instance;

@interface Toast()
@property (nonatomic,strong) UIView *bg;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) void(^block)(void);
@property (nonatomic,strong) NSTimer* timer;
@end

@implementation Toast

+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [Toast new];
        }
    });
    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        _bg = [[UIView alloc]initWithFrame:CGRectZero];
        _bg.backgroundColor = [UIColor blackColor];//[UIColor grayColor];
        [self addSubview:_bg];
        _label = [UIUtil LabelFromFrame:CGRectZero Color:[UIColor whiteColor] Size:13];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        self.alpha = 0;
    }
    return self;
}

-(void)showText:(NSString*)text duration:(NSTimeInterval)duration block:(void(^)(void))block {
    if (_timer) [_timer invalidate];
    
    _block = block;
    
    _label.text = text;
    
    NSInteger n = 1;
    for (int i = 0; i < text.length; i++) {
        if ([text characterAtIndex:i] == '\n') {
            n++;
        }
    }
    
    CGRect frame = CGRectZero;
    CGFloat w = [UIUtil measureLabelWidth:_label MaxWidth:INT_MAX];
    frame.size.width = MIN(kSCREEN_WIDTH-40, w);
    frame.origin.x = (kSCREEN_WIDTH - frame.size.width) / 2;
    NSInteger lines = n > 1 ? n : ceil(w * 2.0f / frame.size.width);
    frame.size.height = lines * 17;
    frame.origin.y = (kSCREEN_HEIGHT - frame.size.height) / 2;
    _label.frame = frame;
    _label.numberOfLines = lines;
    frame.origin.x -= 20;
    frame.origin.y -= 10;
    frame.size.width += 40;
    frame.size.height += 20;
    _bg.frame = frame;
    _bg.layer.cornerRadius = 5;
    
    self.alpha = ALPHA;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(animDismiss) userInfo:nil repeats:NO];
}

-(void)showText:(NSString *)text block:(void (^)(void))block {
    [self showText:text duration:DURATION block:block];
}

-(void)showText:(NSString*)text duration:(NSTimeInterval)duration {
    [self showText:text duration:duration block:nil];
}

-(void)showText:(NSString*)text {
    [self showText:text duration:DURATION block:nil];
}

-(void)animDismiss {
    _timer = nil;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if (finished && !self.timer) {
                             if (self.block) {
                                 self.block();
                                 self.block = nil;
                             }
                             [self removeFromSuperview];
                         }
                     }];
}

- (void)remove {
    [self removeFromSuperview];
    self.alpha = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
