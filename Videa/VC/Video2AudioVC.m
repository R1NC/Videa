//
//  Video2AudioVC.m
//  Videa
//
//  Created by Rinc Liu on 2022/4/18.
//  Copyright © 2022 RINC. All rights reserved.
//

#import "Video2AudioVC.h"
#import "Toast.h"
#import "UIUtil.h"

@interface Video2AudioVC ()

@end

@implementation Video2AudioVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onClickBtnSelect:(id)sender {
    [self selectVideoFromPhotoLibrary];
}

- (IBAction)onClickBtnExport:(id)sender {
    _btnSelectVideo.enabled = NO;
    _btnExport.enabled = NO;
    [self exportAudio];
}

-(void)didReceiveMediaInfo {
    [super didReceiveMediaInfo];
    _btnExport.enabled = self.mediaInfo && self.mediaInfo.getFilename && self.mediaInfo.getFilename.length > 0;
    if (self.mediaInfo && self.mediaInfo.getAllProperties) {
        _tvInfo.text = [NSString stringWithFormat:@"%@", self.mediaInfo.getAllProperties];
    }
}

-(void)didReceiveFFmpegLog:(NSString*)log {
    [super didReceiveFFmpegLog:log];
    [UIUtil textView:_tvInfo appendLine:log];
}

-(void)toastMsg:(NSString*)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Toast shared] showText:msg];
        self.btnSelectVideo.enabled = YES;
        self.btnExport.enabled = YES;
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)exportAudio {
    [self runTask:^{
        NSString* mp3Path = [self tempFileUrlOfExt:@"mp3"];
        NSMutableArray* cmd = [NSMutableArray arrayWithArray:@[
            @"-i", self.mediaInfo.getFilename,
            @"-vn",
            @"-ar", @"44100",
            @"-ac", @"2",
            @"-ab", @"192k",
            @"-f", @"mp3"
        ]];
        [cmd addObject:mp3Path];
        [self exeFFmpegCommand:cmd handler:^(BOOL success) {
            if (success) {
                [self openAudioWithPath:mp3Path];
                [self toastMsg:@"抽取音频成功"];
            } else {
                [self toastMsg:@"抽取音频失败"];
                [self deleteTempFile:mp3Path];
            }
        }];
    }];
}
     
- (void)openAudioWithPath:(NSString*)path {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *items = @[[NSURL fileURLWithPath:path isDirectory:NO]];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    });
}

@end
