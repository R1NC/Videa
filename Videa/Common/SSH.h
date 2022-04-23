//
//  SSH.h
//  Videa
//
//  Created by R1NC on 2022/4/23.
//  Copyright © 2022 RINC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NMSSH/NMSSH.h>

@protocol SSHDelegate<NSObject>

@optional
-(void)onSSHReceivedServerMessage:(NSString*)message;

@end

@interface SSH : NSObject

@property(nonatomic,weak) id<SSHDelegate> delegate;

+(instancetype)shared;

-(BOOL)connectWithHost:(NSString*)host user:(NSString*)user password:(NSString*)password;

-(void)disconnect;

-(void)execCommands:(NSArray<NSString*>*)commands;

-(BOOL)uploadFileLocal:(NSString*)local server:(NSString*)server;

-(NSArray<NMSFTPFile*>*)filesInServerDir:(NSString*)dir;

-(NSData*)dataOfServerFile:(NSString*)file;

@end
