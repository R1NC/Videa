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

@interface M3u8VC ()<UITextFieldDelegate>

@property(nonatomic,assign) NSUInteger pasteboardChangeCount;

@end

@implementation M3u8VC

- (void)viewDidLoad {
    [super viewDidLoad];
    _tvInfo.clipsToBounds = YES;
    _tvInfo.layer.cornerRadius = 6.f;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChangedNotification:) name:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChangedNotification:) name:UIPasteboardRemovedNotification object:[UIPasteboard generalPasteboard]];
    _tvUrl.delegate = self;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [super viewDidDisappear:animated];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self checkUrlString:textField.text]) {
        [self.view endEditing:YES];
        [self download];
    } else {
        [self toastMsg:@"请输入合法的链接"];
        textField.text = nil;
    }
    return NO;
}

- (void)pasteboardChangedNotification:(NSNotification*)notification {
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    _pasteboardChangeCount = pb.changeCount;
    if (pb.strings && pb.strings.count > 0 && pb.strings.firstObject && pb.strings.firstObject.length > 0) {
        if ([self checkUrlString:pb.strings.firstObject]) {
            _tvUrl.text = pb.strings.firstObject;
            [self toastMsg:@"已从剪贴板读取刚复制的链接"];
            [self.view endEditing:YES];
            [self download];
        }
    }
}

-(BOOL)checkUrlString:(NSString*)str {
    if (!str || str.length == 0) return NO;
    NSURL* url = [NSURL URLWithString:str];
    return url && url.scheme && url.host;
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

- (void)download {
    __block NSString* url = _tvUrl.text;
    _tvUrl.enabled = NO;
    if ([url rangeOfString:@".m3u8"].location == NSNotFound) {
        [self runTask:^{
            NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
            if (html && html.length > 0) {
                NSRange rangeM3u8 = [html rangeOfString:@".m3u8"];
                if (rangeM3u8.location != NSNotFound) {
                    NSString* strEndWithM3u8 = [html substringToIndex:rangeM3u8.location + rangeM3u8.length];
                    NSRange rangeHttpScheme = [strEndWithM3u8 rangeOfString:@"http://" options:NSBackwardsSearch];
                    NSRange rangeHttpsScheme = [strEndWithM3u8 rangeOfString:@"https://" options:NSBackwardsSearch];
                    if (rangeHttpScheme.location != NSNotFound) {
                        url = [strEndWithM3u8 substringFromIndex:rangeHttpScheme.location];
                    } else if (rangeHttpsScheme.location != NSNotFound) {
                        url = [strEndWithM3u8 substringFromIndex:rangeHttpsScheme.location];
                    }
                    [self downloadM3u8:url];
                    return;
                }
                [self toastMsg:@"该网页未发现m3u8资源"];
            } else {
                [self toastMsg:@"网页内容抓取失败"];
            }
        }];
    } else {
        [self downloadM3u8:url];
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
}

-(void)downloadM3u8:(NSString*)m3u8 {
    [self runTask:^{
        NSString* mp4Url = [self tempFileUrlOfExt:@"mp4"];
        NSArray* cmd = @[
            @"-i", m3u8,
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

-(void)toastMsg:(NSString*)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Toast shared] showText:msg];
        self.tvUrl.enabled = YES;
    });
}

@end
