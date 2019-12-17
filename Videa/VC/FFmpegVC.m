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
@property(nonatomic,assign) BOOL isWorking;

@end

@implementation FFmpegVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _ipc = [UIImagePickerController new];
    _ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _ipc.mediaTypes = @[(NSString*)kUTTypeMovie];
    if (@available(iOS 11.0, *)) {
        _ipc.videoExportPreset = AVAssetExportPresetPassthrough;
    }
    _ipc.delegate = self;
    _workingQueue = dispatch_queue_create("FFmpeg", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    [MobileFFmpegConfig setLogDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated {
    if (_isWorking) [MobileFFmpeg cancel];
    [super viewDidDisappear:animated];
}

-(void)selctVideoFromPhotoLibrary {
    [self presentViewController:_ipc animated:YES completion:nil];
}

-(void)didReceiveMediaUrl:(NSString*)url info:(MediaInformation *)info {
    NSLog(@"Video info: %@", info.getRawInformation);
}

-(void)didReceiveFFmpegLog:(NSString*)log {
    NSLog(@"%@", log);
}

-(NSString*)tempFileUrlOfExt:(NSString *)ext {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [NSUUID UUID].UUIDString, ext]];
}

-(void)deleteTempFile:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:filePath]) {
         BOOL success = [fileManager removeItemAtPath:filePath error:&error];
         if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
}

-(void)exeFFmpegCommand:(NSString *)cmd handler:(void(^)(BOOL))handler {
    if (cmd && cmd.length > 0) {
        _isWorking = YES;
        [MobileFFmpeg execute:cmd];
        int rc = [MobileFFmpeg getLastReturnCode];
        NSString *output = [MobileFFmpeg getLastCommandOutput];
        BOOL success = rc == RETURN_CODE_SUCCESS;
        if (handler) handler(success);
        if (!success) NSLog(@"FFMpeg command execution failed with rc=%d and output=%@.\n", rc, output);
        _isWorking = NO;
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
            NSString* url = [info[UIImagePickerControllerMediaURL] absoluteString];
            MediaInformation* mediaInfo = [MobileFFmpeg getMediaInformation:url];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didReceiveMediaUrl:url info:mediaInfo];
            });
        }];
    } else {
        [self didReceiveMediaUrl:nil info:nil];
    }
}

#pragma mark LogDelegate

- (void)logCallback: (int)level :(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self didReceiveFFmpegLog:message];
    });
}

@end
