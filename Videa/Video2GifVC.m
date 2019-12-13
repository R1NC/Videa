//
//  Video2GifVC.m
//  Videa
//
//  Created by Rinc Liu on 13/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "Video2GifVC.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <mobileffmpeg/MobileFFmpeg.h>

@interface Video2GifVC () <UIImagePickerControllerDelegate>

@property(nonatomic,strong) UIImagePickerController* ipc;

@end

@implementation Video2GifVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _ipc = [UIImagePickerController new];
    _ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _ipc.mediaTypes = @[(NSString*)kUTTypeMovie];
    _ipc.delegate = self;
    [self presentViewController:_ipc animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [_ipc dismissViewControllerAnimated:YES completion:nil];
    if (info && info[UIImagePickerControllerMediaURL]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* videoUrl = [info[UIImagePickerControllerMediaURL] absoluteString];
            MediaInformation *videoInfo = [MobileFFmpeg getMediaInformation:videoUrl];
            NSLog(@"Video info: %@", videoInfo.getRawInformation);
            NSString* girUrl = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.gif", [NSDate date].timeIntervalSince1970]];
            [MobileFFmpeg execute:[NSString stringWithFormat:@"-i %@ -r 15 %@", videoUrl, girUrl]];
            int rc = [MobileFFmpeg getLastReturnCode];
            NSString *output = [MobileFFmpeg getLastCommandOutput];
            if (rc == RETURN_CODE_SUCCESS) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto fileURL:[NSURL URLWithString:girUrl] options:nil];
                } completionHandler:^(BOOL success, NSError * error) {
                    
                }];
            } else {
                NSLog(@"FFMpeg command execution failed with rc=%d and output=%@.\n", rc, output);
            }
        });
    }
}

@end
