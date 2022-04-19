//
//  Video2AudioVC.h
//  Videa
//
//  Created by Rinc Liu on 2022/4/18.
//  Copyright © 2022 RINC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFmpegVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Video2AudioVC : FFmpegVC

@property (strong, nonatomic) IBOutlet UIButton *btnExport;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectVideo;
@property (strong, nonatomic) IBOutlet UITextView *tvInfo;

@end

NS_ASSUME_NONNULL_END
