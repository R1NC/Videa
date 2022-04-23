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
@property(nonatomic,assign) BOOL connected;

@end

@implementation SSHVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _queue = dispatch_queue_create("SSH", DISPATCH_QUEUE_SERIAL);
    [SSH shared].delegate = self;
}

- (void)dealloc {
    [SSH.shared disconnect];
}

- (IBAction)onPasswordEditEnd:(id)sender {
    [self connect];
}

- (IBAction)onCommandEditEnd:(id)sender {
    if (!self.tfCommand.text || self.tfCommand.text.length == 0) return;
    self.tfCommand.enabled = NO;
    [self exeCmd:self.tfCommand.text];
}

- (IBAction)onClickBtnCtrlC:(id)sender {
    [self exeCmd:@"\x03"];
}

-(void)setKeyBoardBgViewHeight:(CGFloat)height {
    self.constraintBottomViewHeight.constant = height;
    [self.view setNeedsUpdateConstraints];
}

#pragma mark SSH working

- (void)connect {
    if (!self.tfHost.text || self.tfHost.text.length == 0) return;
    if (!self.tfUser.text || self.tfUser.text.length == 0) return;
    if (!self.tfPassword.text || self.tfPassword.text.length == 0) return;
    self.tfHost.enabled = NO;
    self.tfUser.enabled = NO;
    self.tfPassword.enabled = NO;
    self.tfCommand.enabled = NO;
    self.btnCtrlC.enabled = NO;
    NSString* host = self.tfHost.text;
    NSString* user = self.tfUser.text;
    NSString* psw = self.tfPassword.text;
    
    dispatch_async(_queue, ^{
        self.connected = [[SSH shared]connectWithHost:host user:user password:psw];
        runOnUIThread(^{
            self.tfHost.enabled = !self.connected;
            self.tfUser.enabled = !self.connected;
            self.tfPassword.enabled = !self.connected;
            self.tfCommand.enabled = self.connected;
            self.btnCtrlC.enabled = self.connected;
            [[Toast shared] showText:self.connected ? @"连接成功" : @"连接失败"];
        });
    });
}

- (void)exeCmd:(NSString*)cmd {
    if (!self.connected) return;
    dispatch_async(_queue, ^{
        [[SSH shared] execCommands:@[cmd]];
    });
}

#pragma mark SSHDelegate

-(void)onSSHReceivedServerMessage:(NSString *)message {
    runOnUIThread(^{
        self.tfCommand.enabled = YES;
        self.tfCommand.text = nil;
        [UIUtil textView:self.tvConsole appendLine:message];
    });
}

@end
