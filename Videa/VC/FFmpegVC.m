//
//  FFmpegVC.m
//  Videa
//
//  Created by Rinc Liu on 17/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "FFmpegVC.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <ffmpegkit/FFprobeKit.h>

@interface FFmpegVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,strong) UIImagePickerController* ipc;
@property(nonatomic,strong) dispatch_queue_t workingQueue;
@property(nonatomic,assign) BOOL isWorking;
@property(nonatomic,strong) NSString* tempMov;

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
}

-(void)dealloc {
    if (_isWorking) {
        [FFmpegKit cancel];
    }
    if (_tempMov) {
        [[NSFileManager defaultManager] removeItemAtPath:_tempMov error:nil];
    }
}

-(void)selectVideoFromPhotoLibrary {
    [self presentViewController:_ipc animated:YES completion:nil];
}

-(void)didReceiveMediaInfo:(MediaInformation *)mediaInfo {
    NSLog(@"Video info: %@", mediaInfo.getAllProperties);
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

-(void)exeFFmpegCommand:(NSArray<NSString*> *)cmd handler:(void(^)(BOOL))handler {
    if (cmd && cmd.count > 0) {
        _isWorking = YES;
        [FFmpegKit executeWithArgumentsAsync:cmd withExecuteCallback:^(id<Session> session) {
            NSString *output = [session getOutput];
            BOOL success = [[session getReturnCode]isSuccess];
            if (handler) handler(success);
            if (!success) NSLog(@"FFMpeg command execution failed with code=%d and output=%@.\n", [[session getReturnCode]getValue], output);
            self.isWorking = NO;
        } withLogCallback:^(Log *log) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didReceiveFFmpegLog:[log getMessage]];
            });
        } withStatisticsCallback:^(Statistics *statistics) {
            //TODO
        }];
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

#pragma mark UINavigationControllerDelegate

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [_ipc dismissViewControllerAnimated:YES completion:nil];
    if (info && info[UIImagePickerControllerMediaURL]) {
        [self runTask:^{
            NSString* tempMov = [self tempFileUrlOfExt:@"MOV"];
            NSError* err;
            [[NSFileManager defaultManager] copyItemAtURL:info[UIImagePickerControllerMediaURL] toURL:[NSURL fileURLWithPath:tempMov] error:&err];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempMov]) {
                self.tempMov = tempMov;
                MediaInformation* mediaInfo = [[FFprobeKit getMediaInformation:tempMov] getMediaInformation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self didReceiveMediaInfo:mediaInfo];
                });
            }
        }];
    } else {
        [self didReceiveMediaInfo:nil];
    }
}

@end
