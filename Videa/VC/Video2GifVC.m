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

#define FONT_FILE_NAME @"default.ttf"
#define TEMP_FONT_FILE_PATH [NSTemporaryDirectory() stringByAppendingPathComponent:FONT_FILE_NAME]
#define DRAW_TEXT_CMD @"drawtext=text=%@: fontfile=%@: fontcolor=#%@: fontsize=%d: shadowcolor=black@0.5: shadowx=2: shadowy=2: x=(w-text_w)/2: y=(h-text_h*2)"

@interface Video2GifVC ()

@end

@implementation Video2GifVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setKeyBoardBgViewHeight:0];
    [self runTask:^{
        [self checkFontFile];
    }];
}

- (IBAction)onClickBtnSelect:(id)sender {
    [self selectVideoFromPhotoLibrary];
}

- (IBAction)onClickBtnTransform:(id)sender {
    if (!_tfFrameRate.text || _tfFrameRate.text.length == 0 || _tfFrameRate.text.intValue == 0) {
        [self toastMsg:@"请输入帧率"];
        return;
    }
    if (_tvText.text && _tvText.text.length > 0) {
        if (!_tfColor.text || _tfColor.text.length == 0) {
            [self toastMsg:@"请输入文字颜色"];
            return;
        }
        if (_tfColor.text.length != 6) {
            [self toastMsg:@"文字颜色必须是6位16进制RGB"];
            return;
        }
        for (int i = 0; i < _tfColor.text.length; i++) {
            char c = [_tfColor.text characterAtIndex:i];
            if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f')) {
                continue;
            } else {
                [self toastMsg:@"文字颜色必须是6位16进制RGB"];
                return;
            }
        }
        if (!_tfSize.text || _tfSize.text.length == 0) {
            [self toastMsg:@"请输入文字大小"];
            return;
        }
        if (!_tfSize.text || _tfSize.text.intValue == 0) {
            [self toastMsg:@"文字大小必须大于0"];
            return;
        }
    }
    [self transformWithText:_tvText.text color:_tfColor.text size:_tfSize.text.intValue frameRate:_tfFrameRate.text.intValue];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)didReceiveMediaInfo {
    [super didReceiveMediaInfo];
    _btnTransform.enabled = self.hasValidMediaFile;
    if (self.hasValidMediaFile) {
        _tvInfo.text = [NSString stringWithFormat:@"%@", self.mediaInfo.getAllProperties];
    }
}

-(void)didReceiveFFmpegLog:(NSString*)log {
    [super didReceiveFFmpegLog:log];
    [UIUtil textView:_tvInfo appendLine:log];
}

- (void)keyboardWillShow:(CGRect)frame {
    [self setKeyBoardBgViewHeight:frame.size.height];
}

- (void)keyboardWillHide {
    [self setKeyBoardBgViewHeight:0];
}

-(void)transformWithText:(NSString*)text color:(NSString*)color size:(int)size frameRate:(int)frameRate {
    _btnSelectVideo.enabled = NO;
    _btnTransform.enabled = NO;
    _tvText.enabled = NO;
    [self runTask:^{
        NSString* gifUrl = [self tempFileUrlOfExt:@"gif"];
        NSMutableArray* cmd = [NSMutableArray arrayWithArray:@[
            @"-i", self.mediaInfo.getFilename,
            @"-r", [NSString stringWithFormat:@"%d", frameRate]
        ]];
        if (text && text.length > 0) {
            [cmd addObject:@"-vf"];
            [cmd addObject:[NSString stringWithFormat:DRAW_TEXT_CMD, text, TEMP_FONT_FILE_PATH, color, size]];
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

-(void)toastMsg:(NSString*)msg {
    runOnUIThread(^{
        [[Toast shared] showText:msg];
        self.btnSelectVideo.enabled = YES;
        self.btnTransform.enabled = YES;
        self.tvText.enabled = YES;
    });
}

-(void)setKeyBoardBgViewHeight:(CGFloat)height {
    self.constraintHeightOfBottomView.constant = height;
    [self.view setNeedsUpdateConstraints];
}

@end
