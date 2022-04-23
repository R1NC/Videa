//
//  SSHVC.h
//  Videa
//
//  Created by R1NC on 2022/4/23.
//  Copyright © 2022 RINC. All rights reserved.
//

#import "BaseVC.h"


NS_ASSUME_NONNULL_BEGIN

@interface SSHVC : BaseVC

@property (weak, nonatomic) IBOutlet UITextField *tfHost;
@property (weak, nonatomic) IBOutlet UITextField *tfUser;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextView *tvConsole;
@property (weak, nonatomic) IBOutlet UITextField *tfCommand;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomViewHeight;

@end

NS_ASSUME_NONNULL_END
