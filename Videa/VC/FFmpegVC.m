//
//  FFmpegVC.m
//  Videa
//
//  Created by Rinc Liu on 17/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "FFmpegVC.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface FFmpegVC ()<UIImagePickerControllerDelegate, LogDelegate>

@property(nonatomic,strong) UIImagePickerController* ipc;
@property(nonatomic,strong) dispatch_queue_t workingQueue;

@end

@implementation FFmpegVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _ipc = [UIImagePickerController new];
    _ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _ipc.mediaTypes = @[(NSString*)kUTTypeMovie];
    _ipc.delegate = self;
    _workingQueue = dispatch_queue_create("FFmpeg", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    [MobileFFmpegConfig setLogDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated {
    [MobileFFmpeg cancel];
    [super viewDidDisappear:animated];
}

-(void)openPhotoLibrary {
    [self presentViewController:_ipc animated:YES completion:nil];
}

-(void)didReceiveMediaInfo:(MediaInformation*)mediaInfo {
    NSLog(@"Video info: %@", mediaInfo.getRawInformation);
}

-(void)didReceiveFFmpegLog:(NSString*)log {
    NSLog(@"%@", log);
}

-(NSString*)tempFileUrlOfExt:(NSString *)ext {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.%@", [NSDate date].timeIntervalSince1970, ext]];
}

-(void)exeFFmpegCommand:(NSString *)cmd handler:(void(^)(BOOL))handler {
    if (cmd && cmd.length > 0) {
        [MobileFFmpeg execute:cmd];
        int rc = [MobileFFmpeg getLastReturnCode];
        NSString *output = [MobileFFmpeg getLastCommandOutput];
        BOOL success = rc == RETURN_CODE_SUCCESS;
        if (handler) handler(success);
        if (!success) NSLog(@"FFMpeg command execution failed with rc=%d and output=%@.\n", rc, output);
    }
}

-(void)addPhotoLibraryResourceUrl:(NSString*)url type:(PHAssetResourceType)type handler:(void(^)(BOOL))handler {
    if (url && url.length > 0) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:type fileURL:[NSURL URLWithString:url] options:nil];
        } completionHandler:^(BOOL success, NSError * error) {
            if (handler) handler(success);
        }];
    }
}

-(void)runTask:(void (^)(void))task {
    if (task) dispatch_async(self.workingQueue, task);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [_ipc dismissViewControllerAnimated:YES completion:nil];
    if (info && info[UIImagePickerControllerMediaURL]) {
        [self runTask:^{
            MediaInformation* mediaInfo = [MobileFFmpeg getMediaInformation:[info[UIImagePickerControllerMediaURL] absoluteString]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didReceiveMediaInfo:mediaInfo];
            });
        }];
    } else {
        [self didReceiveMediaInfo:nil];
    }
}

#pragma mark LogDelegate

- (void)logCallback: (int)level :(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didReceiveFFmpegLog:message];
    });
}

@end
