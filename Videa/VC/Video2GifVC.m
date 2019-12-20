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

#define FONT_FILE_NAME @"ArialUnicodeMS.ttf"
#define TEMP_FONT_FILE_PATH [NSTemporaryDirectory() stringByAppendingPathComponent:FONT_FILE_NAME]

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
    [_tvText resignFirstResponder];
}

- (IBAction)onClickBtnSelect:(id)sender {
    [self selctVideoFromPhotoLibrary];
}

- (IBAction)onClickBtnTransform:(id)sender {
    [self transformWithText:_tvText.text];
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

-(void)transformWithText:(NSString*)text {
    _btnSelectVideo.enabled = NO;
    _btnTransform.enabled = NO;
    _tvText.enabled = NO;
    [self runTask:^{
        NSString* gifUrl = [self tempFileUrlOfExt:@"gif"];
        [self checkFontFile];
        NSMutableArray* cmd = [NSMutableArray arrayWithArray:@[
            @"-i", self.mediaInfo.getPath,
        ]];
        if (text && text.length > 0) {
            [cmd addObject:@"-vf"];
            [cmd addObject:[NSString stringWithFormat:@"drawtext=text=%@: fontfile=%@: fontcolor=white: fontsize=100: shadowcolor=black@0.5: shadowx=2: shadowy=2: x=(w-text_w)/2: y=(h-text_h*2)", text, TEMP_FONT_FILE_PATH]];
        }
        [cmd addObject:gifUrl];
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

-(void)checkFontFile {
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:TEMP_FONT_FILE_PATH]) {
        NSString* bundleFontFile = [[NSBundle mainBundle] pathForResource:FONT_FILE_NAME ofType:nil];
        [fm copyItemAtPath:bundleFontFile toPath:TEMP_FONT_FILE_PATH error:nil];
    }
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
        self.tvText.enabled = YES;
    });
}

@end
