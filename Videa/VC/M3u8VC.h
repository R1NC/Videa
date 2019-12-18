//
//  M3u8VC.h
//  Videa
//
//  Created by Rinc Liu on 17/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "FFmpegVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface M3u8VC : FFmpegVC
@property (strong, nonatomic) IBOutlet UITextField *tvUrl;
@property (strong, nonatomic) IBOutlet UITextView *tvInfo;

@end

NS_ASSUME_NONNULL_END
