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

@property(nonatomic, strong) MediaInformation* mediaInfo;

@property(nonatomic,strong) UIImagePickerController* ipc;
@property(nonatomic,strong) dispatch_queue_t workingQueue;
@property(nonatomic,assign) BOOL isWorking;
@property(nonatomic,strong) NSString* tempMov;

@end

@implementation FFmpegVC

#pragma mark LifeCycle

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

-(void)viewDidDisappear:(BOOL)animated {
    [self deleteTempVideoFile];
    [super viewDidDisappear:animated];
}

-(void)dealloc {
    if (_isWorking) {
        [FFmpegKit cancel];
    }
    if (_tempMov) {
        [[NSFileManager defaultManager] removeItemAtPath:_tempMov error:nil];
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

#pragma mark ExecuteTask

-(void)runTask:(void (^)(void))task {
    if (task) dispatch_async(self.workingQueue, task);
}

-(void)exeFFmpegCommand:(NSArray<NSString*> *)cmd handler:(void(^)(BOOL))handler {
    if (cmd && cmd.count > 0) {
        _isWorking = YES;
        [FFmpegKit executeWithArgumentsAsync:cmd withCompleteCallback:^(id<Session> session) {
            NSString *output = [session getOutput];
            BOOL success = [[session getReturnCode]isValueSuccess];
            if (handler) handler(success);
            if (!success) NSLog(@"FFMpeg command execution failed with code=%d and output=%@.\n", [[session getReturnCode]getValue], output);
            self.isWorking = NO;
        } withLogCallback:^(Log *log) {
            runOnUIThread(^{
                [self didReceiveFFmpegLog:[log getMessage]];
            });
        } withStatisticsCallback:^(Statistics *statistics) {
            //TODO
        }];
    }
}

-(void)didReceiveFFmpegLog:(NSString*)log {
    NSLog(@"%@", log);
}

#pragma mark PickMedia

-(void)selectVideoFromPhotoLibrary {
    [self presentViewController:_ipc animated:YES completion:nil];
}

-(void)didReceiveMediaInfo {
    NSLog(@"Video info: %@", _mediaInfo ? _mediaInfo.getAllProperties : @{});
}

-(BOOL)hasValidMediaFile {
    return self.mediaInfo && self.mediaInfo.getFilename && self.mediaInfo.getFilename.length > 0 && self.mediaInfo.getAllProperties;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [_ipc dismissViewControllerAnimated:YES completion:nil];
    if (info && info[UIImagePickerControllerMediaURL]) {
        __weak typeof(self) weakSelf = self;
        [self runTask:^{
            __strong typeof(self) strongSelf = weakSelf;
            NSString* tempMov = [strongSelf tempFileUrlOfExt:@"MOV"];
            NSError* err;
            [[NSFileManager defaultManager] copyItemAtURL:info[UIImagePickerControllerMediaURL] toURL:[NSURL fileURLWithPath:tempMov] error:&err];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempMov]) {
                strongSelf.tempMov = tempMov;
                MediaInformation* mediaInfo = [[FFprobeKit getMediaInformation:tempMov] getMediaInformation];
                runOnUIThread(^{
                    strongSelf.mediaInfo = mediaInfo;
                    [strongSelf didReceiveMediaInfo];
                });
            }
        }];
    } else {
        _mediaInfo = nil;
        [self didReceiveMediaInfo];
    }
}

#pragma mark OpenOrStoreMedia

-(void)addPhotoLibraryResourceUrl:(NSString*)url type:(PHAssetResourceType)type handler:(void(^)(BOOL))handler {
    if (url && url.length > 0) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:type fileURL:[NSURL URLWithString:url] options:nil];
        } completionHandler:^(BOOL success, NSError * error) {
            if (handler) handler(success);
        }];
    }
}

-(void)openActivityVCWithPath:(NSString*)path {
    runOnUIThread(^{
        NSArray *items = @[[NSURL fileURLWithPath:path isDirectory:NO]];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    });
}

#pragma mark TempFile

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

-(void)deleteTempVideoFile {
    if (_mediaInfo && _mediaInfo.getFilename && _mediaInfo.getFilename.length > 0) {
        [self deleteTempFile:_mediaInfo.getFilename];
    }
}

@end
