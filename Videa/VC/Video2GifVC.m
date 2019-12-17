//
//  Video2GifVC.m
//  Videa
//
//  Created by Rinc Liu on 13/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "Video2GifVC.h"
#import "Toast.h"
#import "UIUtil.h"

@interface Video2GifVC ()

@property(nonatomic,strong) MediaInformation* mediaInfo;

@end

@implementation Video2GifVC

- (void)viewDidLoad {
    [super viewDidLoad];
    SetTapCallback(self.view, @selector(onTapRoot));
}

-(void)onTapRoot {
    [_tvFrameRate resignFirstResponder];
}

- (IBAction)onClickBtnSelect:(id)sender {
    [self openPhotoLibrary];
}

- (IBAction)onClickBtnTransform:(id)sender {
    if (_tvFrameRate.text && _tvFrameRate.text.integerValue > 0) {
        [self transformWithFrameRate:_tvFrameRate.text.integerValue];
    } else {
        [self toastMsg:@"帧率必须大于0"];
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

-(void)didReceiveMediaInfo:(MediaInformation*)mediaInfo {
    [super didReceiveMediaInfo:mediaInfo];
    _mediaInfo = mediaInfo;
    _btnTransform.enabled = _mediaInfo && _mediaInfo.getPath;
    if (_mediaInfo && _mediaInfo.getRawInformation) _tvInfo.text = _mediaInfo.getRawInformation;
}

-(void)didReceiveFFmpegLog:(NSString*)log {
    [super didReceiveFFmpegLog:log];
    [UIUtil textView:_tvInfo appendLine:log];
}

-(void)transformWithFrameRate:(NSInteger)frameRate {
    _btnTransform.enabled = NO;
    [self runTask:^{
        NSString* gifUrl = [self tempFileUrlOfExt:@"gif"];
        NSString* cmd = [NSString stringWithFormat:@"-i %@ -r %ld %@", _mediaInfo.getPath, frameRate, gifUrl];
        [self exeFFmpegCommand:cmd handler:^(BOOL success) {
            if (success) {
                [self addPhotoLibraryResourceUrl:gifUrl type:PHAssetResourceTypePhoto handler:^(BOOL success) {
                    [self toastMsg:success ? @"GIF保存成功" : @"GIF保存失败"];
                }];
            } else {
                [self toastMsg:@"视频转码失败"];
            }
        }];
    }];
}

-(void)toastMsg:(NSString*)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Toast shared] showText:msg];
        _btnTransform.enabled = YES;
    });
}

@end
