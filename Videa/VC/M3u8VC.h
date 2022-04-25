//
//  M3u8VC.h
//  Videa
//
//  Created by Rinc Liu on 17/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "FFmpegVC.h"
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface M3u8VC : FFmpegVC
@property (strong, nonatomic) IBOutlet UITextField *tvUrl;
@property (strong, nonatomic) IBOutlet UIButton *btnPrev;
@property (strong, nonatomic) IBOutlet UIButton *btnReload;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) IBOutlet UIButton *btnDownload;
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightOfBottomView;

@end

NS_ASSUME_NONNULL_END
