//
//  FFmpegVC.h
//  Videa
//
//  Created by Rinc Liu on 17/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "BaseVC.h"
#import <Photos/Photos.h>
#import <mobileffmpeg/MobileFFmpeg.h>

@interface FFmpegVC : BaseVC

-(void)selctVideoFromPhotoLibrary;

-(void)didReceiveMediaInfo:(MediaInformation *)mediaInfo;

-(void)didReceiveFFmpegLog:(NSString*)log;

-(NSString*)tempFileUrlOfExt:(NSString *)ext;

-(void)deleteTempFile:(NSString*)filePath;

-(void)exeFFmpegCommand:(NSString *)cmd handler:(void(^)(BOOL))handler;

-(void)addPhotoLibraryResourceUrl:(NSString*)url type:(PHAssetResourceType)type handler:(void(^)(BOOL))handler;

-(void)runTask:(void(^)(void))task;

@end
