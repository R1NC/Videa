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

@interface M3u8VC ()

@end

@implementation M3u8VC

- (void)viewDidLoad {
    [super viewDidLoad];
    SetTapCallback(self.view, @selector(onTapRoot));
}

-(void)onTapRoot {
    [_tvUrl resignFirstResponder];
}

- (IBAction)onClickBtnDownload:(id)sender {
    _btnDownload.enabled = NO;
    _tvUrl.enabled = NO;
    __block NSString* url = _tvUrl.text;
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

- (IBAction)didEndEditUrl:(id)sender {
    _btnDownload.enabled = _tvUrl.text && _tvUrl.text.length > 0;
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
        NSString* cmd = [NSString stringWithFormat:@"-protocol_whitelist file,http,https,tcp,tls,crypto -i \"%@\" -c copy %@", m3u8, mp4Url];
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
        self.btnDownload.enabled = YES;
        self.tvUrl.enabled = YES;
    });
}

@end
