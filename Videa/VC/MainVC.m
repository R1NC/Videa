//
//  MainVC.m
//  Videa
//
//  Created by Rinc Liu on 13/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "MainVC.h"
#import "AppPermissionHandler.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AppPermissionHandler checkPhotoLibraryWithHandler:^(BOOL granted) {
        if (!granted) {
            exit(0);
        }
    }];
}

@end
