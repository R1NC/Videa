//
//  SystemSettings.m
//  Videa
//
//  Created by R1NC on 31/07/2017.
//  Copyright © 2017 Rinc Liu. All rights reserved.
//

#import "SystemSettings.h"
#import <UIKit/UIKit.h>

@implementation SystemSettings

//+(void)LocationAuth {
//    [self openRoot:@"Privacy" Path:@"LOCATION"];
//}
//
//+(void)CalendarAuth {
//    [self openRoot:@"Privacy" Path:@"CALENDARS"];
//}
//
//+(void)CameraAuth {
//    [self openRoot:@"Privacy" Path:@"CAMERA"];
//}
//
//+(void)ContactsAuth {
//    [self openRoot:@"Privacy" Path:@"CONTACTS"];
//}
//
//+(void)HealthAuth {
//    [self openRoot:@"Privacy" Path:@"HEALTH"];
//}
//
//+(void)MicrophoneAuth {
//    [self openRoot:@"Privacy" Path:@"MICROPHONE"];
//}
//
//+(void)PhotosAuth {
//    [self openRoot:@"Privacy" Path:@"PHOTOS"];
//}
//
//+(void)ReminderAuth {
//    [self openRoot:@"Privacy" Path:@"REMINDERS"];
//}
//
//+(void)Bluetooth {
//    [self openRoot:@"Bluetooth" Path:nil];
//}
//
//+(void)Wifi {
//    [self openRoot:@"WIFI" Path:nil];
//}
//
//+(void)Notification {
//    [self openRoot:@"NOTIFICATIONS_ID" Path:nil];
//}

+(void)myApp {
    [self openURL:UIApplicationOpenSettingsURLString];
}

//+(void)root {
//    [self openURL:@"App-Prefs:root=www"];
//}
//
//+(void)openRoot:(NSString*)root Path:(NSString*)path {
//    if (@available(iOS 11.0, *)) {
//        if (root && [root isEqualToString:@"WIFI"]) {
//            [self root];
//        } else if (root && [root isEqualToString:@"Bluetooth"]) {
//            [self root];
//        }
//        else {
//            [self myApp];
//        }
//    } else {
//        [self openURL:[NSString stringWithFormat:@"App-Prefs:root=%@&path=%@", root, path]];
//    }
//}

+(void)openURL:(NSString*)urlStr {
    NSURL* url = [NSURL URLWithString:urlStr];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [app openURL:url options:[NSDictionary new] completionHandler:nil];
        } else {
            [app openURL:url];
        }
    }
}

@end
