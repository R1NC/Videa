//
//  BaseVC.m
//  Videa
//
//  Created by Rinc Liu on 18/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "BaseVC.h"
#import "UIUtil.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveN:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveN:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundN:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundN:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowN:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideN:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowN:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideN:) name:UIKeyboardDidHideNotification object:nil];
    SetTapCallback(self.view, @selector(onTapRoot));
}

-(void)onTapRoot {
    [self.view endEditing:YES];
}

-(void)viewDidDisappearN:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)didBecomeActiveN:(NSNotification *)notification {
    [self didBecomeActive];
}

- (void)willResignActiveN:(NSNotification *)notification {
    [self willResignActive];
}

- (void)didEnterBackgroundN:(NSNotification *)notification {
    [self didEnterBackground];
}

- (void)willEnterForegroundN:(NSNotification *)notification {
    [self willEnterForeground];
}

- (void)keyboardWillShowN:(NSNotification *)notification {
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [self.view convertRect:[value CGRectValue] fromView:nil];
    [self keyboardWillShow:keyboardFrame];
}

- (void)keyboardWillHideN:(NSNotification *)notification {
    [self keyboardWillHide];
}

- (void)keyboardDidShowN:(NSNotification *)notification {
    NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [self.view convertRect:[value CGRectValue] fromView:nil];
    [self keyboardDidShow:keyboardFrame];
}

- (void)keyboardDidHideN:(NSNotification *)notification {
    [self keyboardDidHide];
}

- (void)didBecomeActive {}

- (void)willResignActive {}

- (void)didEnterBackground {}

- (void)willEnterForeground {}

- (void)keyboardWillShow:(CGRect)frame {}

- (void)keyboardWillHide {}

- (void)keyboardDidShow:(CGRect)frame {}

- (void)keyboardDidHide {}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
