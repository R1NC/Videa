//
//  SSHVC.m
//  Videa
//
//  Created by R1NC on 2022/4/23.
//  Copyright © 2022 RINC. All rights reserved.
//

#import "SSHVC.h"
#import "UIUtil.h"
#import "Toast.h"
#import "SSH.h"

@interface SSHVC()<SSHDelegate>

@property(nonatomic,strong) dispatch_queue_t queue;

@end

@implementation SSHVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)setKeyBoardBgViewHeight:(CGFloat)height {
    self.constraintBottomViewHeight.constant = height;
    [self.view setNeedsUpdateConstraints];
    
    _queue = dispatch_queue_create("SSH", DISPATCH_QUEUE_SERIAL);
    [SSH shared].delegate = self;
}

#pragma mark SSH working

- (void)connect {
    if (!self.tfHost.text || self.tfHost.text.length == 0) return;
    if (!self.tfUser.text || self.tfUser.text.length == 0) return;
    if (!self.tfPassword.text || self.tfPassword.text.length == 0) return;
    self.tfHost.enabled = NO;
    self.tfUser.enabled = NO;
    self.tfPassword.enabled = NO;
    NSString* host = self.tfHost.text;
    NSString* user = self.tfUser.text;
    NSString* psw = self.tfPassword.text;
    
    dispatch_async(_queue, ^{
        BOOL success = [[SSH shared]connectWithHost:host user:user password:psw];
        runOnUIThread(^{
            self.tfHost.enabled = !success;
            self.tfUser.enabled = !success;
            self.tfPassword.enabled = !success;
            [[Toast shared] showText:success ? @"连接成功" : @"连接失败"];
        });
    });
}

- (void)exeCmd {
    if (!self.tfCommand.text || self.tfCommand.text.length == 0) return;
    self.tfCommand.enabled = NO;
    NSString* cmd = self.tfCommand.text;
    
    dispatch_async(_queue, ^{
        [[SSH shared] execCommands:@[cmd]];
    });
}

#pragma mark SSHDelegate

-(void)onSSHReceivedServerMessage:(NSString *)message {
    [UIUtil textView:self.tvConsole appendLine:message];
}

@end
