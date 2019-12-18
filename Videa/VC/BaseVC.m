//
//  BaseVC.m
//  Videa
//
//  Created by Rinc Liu on 18/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)didBecomeActive:(NSNotification *)notification {
    [self didBecomeActive];
}

- (void)willResignActive:(NSNotification *)notification {
    [self willResignActive];
}

- (void)didEnterBackground:(NSNotification *)notification {
    [self didEnterBackground];
}

- (void)willEnterForeground:(NSNotification *)notification {
    [self willEnterForeground];
}

- (void)didBecomeActive {}

- (void)willResignActive {}

- (void)didEnterBackground {}

- (void)willEnterForeground {}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
