//
//  SSH.m
//  Videa
//
//  Created by R1NC on 2022/4/23.
//  Copyright © 2022 RINC. All rights reserved.
//

#import "SSH.h"

@interface SSH()<NMSSHSessionDelegate,NMSSHChannelDelegate>

@property(nonatomic,strong) NMSSHSession *cmdSession, *ftpSession;
@property(nonatomic,strong) NMSFTP* sftp;

@end

@implementation SSH

+(instancetype)shared {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [self new];
        }
    });
    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        //TODO
    }
    return self;
}

-(BOOL)connectWithHost:(NSString*)host user:(NSString*)user password:(NSString*)password {
    _cmdSession = [self createSessionWithHost:host user:user password:password shell:YES];
    _ftpSession = [self createSessionWithHost:host user:user password:password shell:NO];
    _sftp = [[NMSFTP alloc]initWithSession:_ftpSession];
    return [self checkSession:_cmdSession] && [self checkSession:_ftpSession];
}

-(void)disconnect {
    [self closeSession:_cmdSession shell:YES];
    [self closeSession:_ftpSession shell:NO];
}

-(NMSSHSession*)createSessionWithHost:(NSString*)host user:(NSString*)user password:(NSString*)password shell:(BOOL)shell {
    NMSSHSession* session = [NMSSHSession connectToHost:host withUsername:user];
    if (session.isConnected) {
        [session authenticateByPassword:password];
        if (session.isAuthorized) {
            NSError *error = nil;
            session.delegate = self;
            session.channel.delegate = self;
            if (shell) {
                session.channel.requestPty = YES;
                [session.channel startShell:&error];
            }
        }
    }
    return session;
}

-(BOOL)checkSession:(NMSSHSession*)session {
    return session && session.isConnected && session.isAuthorized;
}

-(void)closeSession:(NMSSHSession*)session shell:(BOOL)shell {
    if ([self checkSession:session]) {
        if (shell) {
            [session.channel closeShell];
        } else {
            if (session.sftp.isConnected) {
                [session.sftp disconnect];
            }
        }
        [session disconnect];
    }
}

-(void)execCommands:(NSArray<NSString*>*)commands {
    if ([self checkSession:_cmdSession] && commands && commands.count > 0) {
        NSError *error = nil;
        for (NSString* cmd in commands) {
            [_cmdSession.channel write:[NSString stringWithFormat:@"%@\n", cmd] error:&error];
        }
    }
}

-(BOOL)uploadFileLocal:(NSString*)local server:(NSString*)server {
    if ([self checkSession:_ftpSession] && _sftp && local && local.length > 0 && server && server.length > 0) {
        if (!_sftp.isConnected) [_sftp connect];
        if (_sftp.isConnected) {
            return [_sftp writeFileAtPath:local toFileAtPath:server];
        }
    }
    return NO;
}

-(NSArray<NMSFTPFile*>*)filesInServerDir:(NSString*)dir {
    if ([self checkSession:_ftpSession] && _sftp && dir && dir.length > 0) {
        if (!_sftp.isConnected) [_sftp connect];
        if (_sftp.isConnected && [_sftp directoryExistsAtPath:dir]) {
            return [_sftp contentsOfDirectoryAtPath:dir];
        }
    }
    return nil;
}

-(NSData*)dataOfServerFile:(NSString *)file {
    if ([self checkSession:_ftpSession] && _sftp && file && file.length > 0) {
        if (!_sftp.isConnected) [_sftp connect];
        if (_sftp.isConnected && [_sftp fileExistsAtPath:file]) {
            return [_sftp contentsAtPath:file];
        }
    }
    return nil;
}

#pragma mark NMSSHSessionDelegate

/**
 Called when the session is setup to use keyboard interactive authentication, and the server is sending back a question (e.g. a password request).
 @param session The session that is asking
 @param request Question from server
 @returns A valid response to the given question
 */
- (NSString *)session:(NMSSHSession *)session keyboardInteractiveRequest:(NSString *)request {
    if (request) {
        
    }
    return nil;
}

/**
 Called when a session has failed and disconnected.
 @param session The session that was disconnected
 @param error A description of the error that caused the disconnect
 */
- (void)session:(NMSSHSession *)session didDisconnectWithError:(NSError *)error {
    if (error);
}

/**
 Called when a session is connecting to a host, the fingerprint is used to verify the authenticity of the host.
 @param session The session that is connecting
 @param fingerprint The host's fingerprint
 @returns YES if the session should trust the host, otherwise NO.
 */
- (BOOL)session:(NMSSHSession *)session shouldConnectToHostWithFingerprint:(NSString *)fingerprint {
    return YES;
}

#pragma mark NMSSHChannelDelegate

/**
 Called when a channel read new data on the socket.
 @param channel The channel that read the message
 @param message The message that the channel has read
 */
- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message {
    if (_delegate) [_delegate onSSHReceivedServerMessage:message];
}

/**
 Called when a channel read new error on the socket.
 @param channel The channel that read the error
 @param error The error that the channel has read
 */
- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error {
    if (error);
}

/**
 Called when a channel read new data on the socket.
 @param channel The channel that read the message
 @param data The bytes that the channel has read
 */
- (void)channel:(NMSSHChannel *)channel didReadRawData:(NSData *)data {
    if (data);
}

/**
 Called when a channel read new error on the socket.
 @param channel The channel that read the error
 @param error The error that the channel has read
 */
- (void)channel:(NMSSHChannel *)channel didReadRawError:(NSData *)error {
    if (error);
}

/**
 Called when a channel in shell mode has been closed.
 @param channel The channel that has been closed
 */
- (void)channelShellDidClose:(NMSSHChannel *)channel {
    
}

@end
