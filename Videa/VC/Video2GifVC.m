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

-(void)viewDidDisappear:(BOOL)animated {
    [self deleteTempVideoFile];
    [super viewDidDisappear:animated];
}

-(void)onTapRoot {
    [_tvFrameRate resignFirstResponder];
}

- (IBAction)onClickBtnSelect:(id)sender {
    [self selctVideoFromPhotoLibrary];
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

-(void)didReceiveMediaInfo:(MediaInformation *)mediaInfo {
    [super didReceiveMediaInfo:mediaInfo];
    [self deleteTempVideoFile];
    _mediaInfo = mediaInfo;
    _btnTransform.enabled = _mediaInfo && _mediaInfo.getPath && _mediaInfo.getPath.length > 0;
    if (_mediaInfo && _mediaInfo.getRawInformation) _tvInfo.text = _mediaInfo.getRawInformation;
}

-(void)didReceiveFFmpegLog:(NSString*)log {
    [super didReceiveFFmpegLog:log];
    [UIUtil textView:_tvInfo appendLine:log];
}

-(void)transformWithFrameRate:(NSInteger)frameRate {
    _btnSelectVideo.enabled = NO;
    _btnTransform.enabled = NO;
    _tvFrameRate.enabled = NO;
    [self runTask:^{
        NSString* gifUrl = [self tempFileUrlOfExt:@"gif"];
        NSString* cmd = [NSString stringWithFormat:@"-i %@ -r %ld %@", self.mediaInfo.getPath, frameRate, gifUrl];
        [self exeFFmpegCommand:cmd handler:^(BOOL success) {
            if (success) {
                __weak typeof(self) weakSelf = self;
                [self addPhotoLibraryResourceUrl:gifUrl type:PHAssetResourceTypePhoto handler:^(BOOL success) {
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf toastMsg:success ? @"GIF 保存成功" : @"GIF 保存失败"];
                    if (!success) [strongSelf deleteTempFile:gifUrl];
                }];
            } else {
                [self toastMsg:@"视频转码失败"];
                [self deleteTempFile:gifUrl];
            }
        }];
    }];
}

-(void)deleteTempVideoFile {
    if (_mediaInfo && _mediaInfo.getPath && _mediaInfo.getPath.length > 0) {
        [self deleteTempFile:_mediaInfo.getPath];
    }
}

-(void)toastMsg:(NSString*)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Toast shared] showText:msg];
        self.btnSelectVideo.enabled = YES;
        self.btnTransform.enabled = YES;
        self.tvFrameRate.enabled = YES;
    });
}

@end
