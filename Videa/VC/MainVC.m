//
//  MainVC.m
//  Videa
//
//  Created by Rinc Liu on 13/12/2019.
//  Copyright © 2019 RINC. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkPhotoLibraryWithHandler:^(BOOL granted) {
        if (granted) {
            [self checkCameraWithHandler:^(BOOL granted) {
                if (granted) {
                    [self checkRecordWithHandler:^(BOOL granted) {
                        if (granted) {
                            //TODO
                        } else {
                            exit(0);
                        }
                    }];
                } else {
                    exit(0);
                }
            }];
        } else {
           exit(0);
        }
    }];
}

@end
