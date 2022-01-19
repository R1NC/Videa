//
//  Video2GifVC.h
//  Videa
//
//  Created by Rinc Liu on 13/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "FFmpegVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface Video2GifVC : FFmpegVC
@property (strong, nonatomic) IBOutlet UITextField *tvText;
@property (strong, nonatomic) IBOutlet UIButton *btnTransform;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectVideo;
@property (strong, nonatomic) IBOutlet UITextView *tvInfo;
@property (strong, nonatomic) IBOutlet UITextField *tfColor;
@property (strong, nonatomic) IBOutlet UITextField *tfSize;
@property (strong, nonatomic) IBOutlet UITextField *tfFrameRate;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightOfBottomView;

@end

NS_ASSUME_NONNULL_END
