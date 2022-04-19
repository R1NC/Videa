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

@property(nonatomic,strong) MediaInformation* mediaInfo;

-(void)selectVideoFromPhotoLibrary;

-(void)didReceiveMediaInfo;

-(void)didReceiveFFmpegLog:(NSString*)log;

-(NSString*)tempFileUrlOfExt:(NSString *)ext;

-(void)deleteTempFile:(NSString*)filePath;

-(void)exeFFmpegCommand:(NSArray<NSString*> *)cmd handler:(void(^)(BOOL))handler;

-(void)addPhotoLibraryResourceUrl:(NSString*)url type:(PHAssetResourceType)type handler:(void(^)(BOOL))handler;

-(void)runTask:(void(^)(void))task;

-(void)deleteTempVideoFile;

@end
