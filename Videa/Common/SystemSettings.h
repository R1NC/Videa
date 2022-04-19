//
//  SystemSettings.h
//  Videa
//
//  Created by R1NC on 31/07/2017.
//  Copyright © 2017 Rinc Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemSettings : NSObject

//+(void)LocationAuth;
//
//+(void)CalendarAuth;
//
//+(void)CameraAuth;
//
//+(void)ContactsAuth;
//
//+(void)HealthAuth;
//
//+(void)MicrophoneAuth;
//
//+(void)PhotosAuth;
//
//+(void)ReminderAuth;
//
//+(void)Bluetooth;
//
//+(void)Wifi;
//
//+(void)Notification;

+(void)myApp:(void (^ __nullable)(BOOL success))completion;

//+(void)root;

@end
