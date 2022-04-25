//
//  M3u8VC.m
//  Videa
//
//  Created by Rinc Liu on 17/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "M3u8VC.h"
#import "Toast.h"
#import "UIUtil.h"
#import<AVKit/AVKit.h>
#import<AVFoundation/AVFoundation.h>

#define DEFAULT_TIME_TEXT @"00:00:00.00"

@interface M3u8VC ()<UITextFieldDelegate>

@property(nonatomic,assign) NSUInteger pasteboardChangeCount;
@property(nonatomic,strong) AVPlayerViewController* avpVC;
@property(nonatomic,strong) NSString* m3u8Url;

@property(nonatomic,assign) BOOL durationIsReady;
@property(nonatomic,assign) NSInteger duration;

@end

@implementation M3u8VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChangedNotification:) name:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChangedNotification:) name:UIPasteboardRemovedNotification object:[UIPasteboard generalPasteboard]];
    _tvUrl.delegate = self;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    _avpVC = [AVPlayerViewController new];
    _avpVC.allowsPictureInPicturePlayback = YES;
    _progressView.progress = 0;
}

- (void)dealloc:(BOOL)animated {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self checkM3u8Url:textField.text handler:^(BOOL valid) {
        if (!valid) {
            [self toastMsg:@"链接不合法或者没有找到 m3u8 资源"];
            textField.text = nil;
        }
    }];
    return NO;
}

- (void)pasteboardChangedNotification:(NSNotification*)notification {
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    _pasteboardChangeCount = pb.changeCount;
    if (pb.strings && pb.strings.count > 0 && pb.strings.firstObject && pb.strings.firstObject.length > 0) {
        [self checkM3u8Url:pb.strings.firstObject handler:^(BOOL valid) {
        }];
    }
}

- (IBAction)onClickBtnPlay:(id)sender {
    [self playM3u8];
}

- (IBAction)onClickBtnDownload:(id)sender {
    [self downloadM3u8];
}

-(void)willResignActive {
    _pasteboardChangeCount = [UIPasteboard generalPasteboard].changeCount;
    [super willResignActive];
}

-(void)didBecomeActive {
    [super didBecomeActive];
    if (_pasteboardChangeCount < [UIPasteboard generalPasteboard].changeCount) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)didReceiveFFmpegLog:(NSString*)log {
    [super didReceiveFFmpegLog:log];
    [UIUtil textView:_tvInfo appendLine:log];
    
    if (self.durationIsReady) {
        self.labelDuration.text = log;
        self.duration = [self parseTimerStr:log];
    }
    self.durationIsReady = [log rangeOfString:@"Duration:"].location != NSNotFound;
    
    NSRange timeRange = [log rangeOfString:@"time="];
    if (timeRange.location != NSNotFound) {
        NSString *s0 = [log substringFromIndex:timeRange.location + 5];
        NSString *s1 = [s0 substringToIndex:[s0 rangeOfString:@" "].location];
        self.labelTime.text = s1;
        NSInteger time = [self parseTimerStr:s1];
        if (self.duration > 0 && time >= 0 && time <= self.duration) {
            self.progressView.progress = time * 1.0 / self.duration;
        }
    }
}

- (NSInteger)parseTimerStr:(NSString*)str {
    NSArray<NSString*> *arr = [str componentsSeparatedByString:@":"];
    return 3600 * [self intWithStr:arr[0]] + 60 * [self intWithStr:arr[1]] + [self intWithStr:arr[2]];
}

- (NSInteger)intWithStr:(NSString*)str {
    if ([str rangeOfString:@"0"].location == 0) {
        return [str substringFromIndex:1].integerValue;
    }
    return str.integerValue;
}

-(void)checkM3u8Url:(NSString*)urlStr handler:(void(^)(BOOL))handler {
    void(^validBlock)(NSString*) = ^(NSString* url) {
        self.m3u8Url = url;
        runOnUIThread(^{
            [self.view endEditing:YES];
            self.tvUrl.text = url;
            self.avpVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:url]];
            self.btnPlay.enabled = YES;
            self.btnDownload.enabled = YES;
            if (handler) handler(YES);
        });
    };
    void(^invalidBlock)(void) = ^ {
        runOnUIThread(^{
            [self.view endEditing:YES];
            self.btnPlay.enabled = NO;
            self.btnDownload.enabled = NO;
            if (handler) handler(NO);
        });
    };
    if (urlStr && urlStr.length > 0) {
        NSURL* url = [NSURL URLWithString:urlStr];
        if (url && url.scheme && url.host) {
            if ([urlStr rangeOfString:@".m3u8"].location == NSNotFound) {
                self.durationIsReady = NO;
                self.duration = 0;
                self.progressView.progress = 0;
                self.labelTime.text = DEFAULT_TIME_TEXT;
                self.labelDuration.text = DEFAULT_TIME_TEXT;
                
                [self runTask:^{
                    NSString* html = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:nil];
                    if (html && html.length > 0) {
                        NSRange rangeM3u8 = [html rangeOfString:@".m3u8"];
                        if (rangeM3u8.location != NSNotFound) {
                            NSString* strEndWithM3u8 = [html substringToIndex:rangeM3u8.location + rangeM3u8.length];
                            NSRange rangeHttpScheme = [strEndWithM3u8 rangeOfString:@"http://" options:NSBackwardsSearch];
                            NSRange rangeHttpsScheme = [strEndWithM3u8 rangeOfString:@"https://" options:NSBackwardsSearch];
                            NSString* newUrl = nil;
                            if (rangeHttpScheme.location != NSNotFound) {
                                newUrl = [strEndWithM3u8 substringFromIndex:rangeHttpScheme.location];
                            } else if (rangeHttpsScheme.location != NSNotFound) {
                                newUrl = [strEndWithM3u8 substringFromIndex:rangeHttpsScheme.location];
                            }
                            if (newUrl) {
                                validBlock(newUrl);
                            }
                            return;
                        }
                    }
                    invalidBlock();
                }];
            } else {
                validBlock(urlStr);
            }
            return;
        }
    }
    invalidBlock();
}

-(void)downloadM3u8 {
    [self runTask:^{
        NSString* mp4Url = [self tempFileUrlOfExt:@"mp4"];
        NSArray* cmd = @[
            @"-i", self.m3u8Url,
            @"-protocol_whitelist", @"file,http,https,tcp,tls,crypto",
            @"-c", @"copy",
            mp4Url
        ];
        [self exeFFmpegCommand:cmd handler:^(BOOL success) {
            if (success) {
                __weak typeof(self) weakSelf = self;
                [self addPhotoLibraryResourceUrl:mp4Url type:PHAssetResourceTypeVideo handler:^(BOOL success) {
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf toastMsg:success ? @"视频保存成功" : @"视频保存失败"];
                    if (!success) [strongSelf deleteTempFile:mp4Url];
                }];
            } else {
                [self toastMsg:@"视频下载失败"];
                [self deleteTempFile:mp4Url];
            }
        }];
    }];
}

-(void)playM3u8 {
    [_avpVC.player play];
    [self presentViewController:_avpVC animated:YES completion:nil];
}

-(void)toastMsg:(NSString*)msg {
    runOnUIThread(^{
        [[Toast shared] showText:msg];
        self.tvUrl.enabled = YES;
    });
}

-(void)setKeyBoardBgViewHeight:(CGFloat)height {
    self.constraintHeightOfBottomView.constant = height;
    [self.view setNeedsUpdateConstraints];
}

@end
