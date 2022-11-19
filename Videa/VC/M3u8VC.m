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
#import <WebKit/WebKit.h>

#define DEFAULT_TIME_TEXT @"00:00:00.00"

@interface M3u8VC ()<UITextFieldDelegate, WKNavigationDelegate, WKUIDelegate>

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
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.configuration.allowsInlineMediaPlayback = YES;
    self.webView.configuration.allowsAirPlayForMediaPlayback = YES;
    self.webView.configuration.allowsPictureInPictureMediaPlayback = YES;
    self.webView.configuration.preferences.minimumFontSize = 10;
    self.webView.configuration.preferences.javaScriptEnabled = YES;
    if (@available(iOS 14.5, *)) {
        self.webView.configuration.preferences.textInteractionEnabled = YES;
    }
    self.webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
}

-(void)willMoveToParentViewController:(nullable UIViewController *)vc {
    [super willMoveToParentViewController:vc];
    [self stopLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.tvUrl) {
        return [self loadUrl:self.tvUrl.text];
    }
    return NO;
}

- (BOOL)loadUrl:(NSString*)url {
    if (url && url.length > 0) {
        [self stopLoad];
        /*if ([url rangeOfString:@"http://"].location == NSNotFound || [url rangeOfString:@"https://"].location == NSNotFound) {
            url = [@"http://" stringByAppendingString:url];
        }*/
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        return YES;
    }
    return NO;
}

- (void)stopLoad {
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
}

- (void)pasteboardChangedNotification:(NSNotification*)notification {
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    _pasteboardChangeCount = pb.changeCount;
    if (pb.strings && pb.strings.count > 0 && pb.strings.firstObject && pb.strings.firstObject.length > 0) {
        if ([self loadUrl:pb.strings.firstObject]) {
            self.tvUrl.text = pb.strings.firstObject;
        }
    }
}

- (IBAction)onClickBtnPrev:(id)sender {
    if (self.webView.canGoBack) {
        [self stopLoad];
        [self.webView goBack];
    }
}

- (IBAction)onClickBtnReload:(id)sender {
    if (self.webView.canGoBack) {
        [self stopLoad];
        [self.webView reload];
    }
}

- (IBAction)onClickBtnNext:(id)sender {
    if (self.webView.canGoForward) {
        [self stopLoad];
        [self.webView goForward];
    }
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

#pragma mark WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
  if (!navigationAction.targetFrame.isMainFrame) {
      [webView loadRequest:navigationAction.request];
  }
  return nil;
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    self.tvUrl.text = self.webView.URL.absoluteString;
    self.btnDownload.enabled = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    self.tvUrl.text = self.webView.URL.absoluteString;
    self.btnPrev.enabled = self.webView.canGoBack;
    self.btnReload.enabled = YES;
    self.btnNext.enabled = self.webView.canGoForward;
    [self checkM3u8Url:self.tvUrl.text handler:^(BOOL valid) {
        self.btnDownload.enabled = valid;
    }];
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
            self.avpVC.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:url]];
            self.btnDownload.enabled = YES;
            if (handler) handler(YES);
        });
    };
    void(^invalidBlock)(void) = ^ {
        runOnUIThread(^{
            [self.view endEditing:YES];
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
