//
//  MLXMPPManager.m
//  XMPPFrameworkDemo
//
//  Created by mjpc on 16/5/7.
//  Copyright © 2016年 mali. All rights reserved.
//  http://www.jianshu.com/users/e5c4518a950d
//

#import "MLXMPPManager.h"
#import "GCDAsyncSocket.h"


NSString * const MLXMPPDomain   = @"localhost";
NSString * const MLXMPPHostName = @"localhost";
static NSString * const KXMPPResource = @"xmppDemo";

NSString *_user = @"";
NSString *_password = @"";

@implementation MLXMPPManager

#pragma mark - ****************  Singleton

+ (instancetype)sharedManager {
    static MLXMPPManager *xmppManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppManager = [self new];
        [xmppManager configStream];
    });
    return xmppManager;
}

#pragma mark - ****************  Public Methods

- (void)connectThenLoginWith:(NSString *)user andPassword:(NSString *)password {
    
    if (user.length < 1 || password.length < 1) {
        return ;
    }
    _user = user;
    _password = password;
    
    if ([_xmppStream isConnecting] || [_xmppStream isConnected]) {
        _loginSuccess();
        return;
    }
    if ([_xmppStream isDisconnected]) {
        [self connect];
        _doRegisterAfterConnected = NO;
    }
    else {
        [self doLogin];
    }
}

/** TODO:发送群聊消息*/
- (void)sendToGroupWithMessage:(NSString *)message {
    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"groupchat"];
    [msg addBody:message];
    [_xmppRoom sendMessage:msg];
}

- (void)joinRoomWith:(NSString *)nickName toRoomJID:(XMPPJID *)jid {
    
    if (!_xmppRoom) {
        [self configRoomWithJID:jid];
    }
    
    [_xmppRoom joinRoomUsingNickname:nickName history:nil];
}

#pragma mark - ****************  Pirvate Methods

- (void)configStream {
    _xmppStream = [XMPPStream new];
    _xmppReconnect  = [XMPPReconnect new];
    [_xmppReconnect activate:_xmppStream];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)cutDownStream {
    [_xmppStream removeDelegate:self];
    [_xmppReconnect deactivate];
    [_xmppStream disconnect];
    _xmppStream = nil;
    _xmppReconnect = nil;
}

- (BOOL)connect{
    
    if (![_xmppStream isDisconnected]) {
        return YES;
    }
    [_xmppStream setMyJID:[XMPPJID jidWithUser:_user domain:MLXMPPDomain resource:KXMPPResource]];
    [_xmppStream setHostName:MLXMPPHostName];
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"Error connecting: %@", error);
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    [self doOffline];
    [_xmppStream disconnect];
}

- (void)doOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)doOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailabel"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)doLogin{
    
    NSError *error = nil;
    if (![[self xmppStream] authenticateWithPassword:_password error:&error])
    {
        NSLog(@"Error authenticating: %@", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)doRegister {
    
    NSError *error = nil;
    if ([_xmppStream isConnected] && [_xmppStream supportsInBandRegistration]) {
        
        if (_user.length < 1 || _password.length < 1) {
            return NO;
        }
        [_xmppStream setMyJID:[XMPPJID jidWithUser:_user domain:MLXMPPDomain resource:KXMPPResource]];
        if (![_xmppStream registerWithPassword:_password error:&error]) {
            NSLog(@"Error connecting: %@", error);
            return NO;
        }
    }
    return YES;
}

- (void)connectThenRegister
{
    if ([_xmppStream isDisconnected]) {
        _doRegisterAfterConnected = YES;
        [self connect];
    }
    else {
        [self doRegister];
    }
}


/** TODO:单聊*/
- (void)sendChatMessage:(NSString *)plainMessage toJID:(XMPPJID *)jid {
    if (plainMessage.length > 0 && jid.user.length > 0) {
        XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat" to:jid];
        [msg addBody:plainMessage];
        [self.xmppStream sendElement:msg];
        
    }
}

- (void)configRoomWithJID:(XMPPJID *)jid {
    XMPPRoomCoreDataStorage *rosterstorage = [[XMPPRoomCoreDataStorage alloc] init];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:rosterstorage jid:jid
                                        dispatchQueue:dispatch_get_main_queue()];
    
    [_xmppRoom activate:_xmppStream];
}

- (void)leaveRoom {
    [_xmppRoom deactivate];
    _xmppRoom = nil;
}

- (void)changeNickname:(NSString *)newNickname {
    if (_xmppRoom.isJoined) {
        [_xmppRoom changeNickname:newNickname];
    }
}


#pragma mark - ****************  XMPPDelegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    NSLog(@"socketDidConnect:");
}


- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidConnect:");
    
    _isXMPPConnected = YES;
    
    if (_doRegisterAfterConnected) {
        [self doRegister];
    }
    else {
        [self doLogin];
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    [self doLogin];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    [self connectThenRegister];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"xmppStreamDidAuthenticate:");
    
    _loginSuccess();
    [self doOffline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"didNotAuthenticate");
    //未登录成功去注册
    [self connectThenRegister];
}

/** TODO:处理接收到的群聊消息*/
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"didReceiveMessage:");
    _didReceiveMessage(message);
    
}


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"xmppStreamDidDisconnect:");
    
    if (!_isXMPPConnected)
    {
        NSLog(@"Unable to connect to server");
    }
}

@end
