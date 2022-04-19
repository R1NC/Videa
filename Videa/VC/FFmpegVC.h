//
//  FFmpegVC.h
//  Videa
//
//  Created by Rinc Liu on 17/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "BaseVC.h"
#import <Photos/Photos.h>
#import <ffmpegkit/FFmpegKit.h>

@interface FFmpegVC : BaseVC

@property(nonatomic, readonly) MediaInformation* mediaInfo;

/// Execute task
-(void)runTask:(void(^)(void))task;
-(void)exeFFmpegCommand:(NSArray<NSString*> *)cmd handler:(void(^)(BOOL))handler;
-(void)didReceiveFFmpegLog:(NSString*)log;

/// Pick media file
-(void)selectVideoFromPhotoLibrary;
-(void)didReceiveMediaInfo;
-(BOOL)hasValidMediaFile;

/// Open or store media file
-(void)addPhotoLibraryResourceUrl:(NSString*)url type:(PHAssetResourceType)type handler:(void(^)(BOOL))handler;
-(void)openActivityVCWithPath:(NSString*)path;

/// Handle temp file
-(NSString*)tempFileUrlOfExt:(NSString *)ext;
-(void)deleteTempFile:(NSString*)filePath;

@end
