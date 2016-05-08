//
//  MLXMPPManager.h
//  XMPPFrameworkDemo
//
//  Created by mjpc on 16/5/7.
//  Copyright © 2016年 mali. All rights reserved.
//  http://www.jianshu.com/users/e5c4518a950d
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPReconnect.h"

@interface MLXMPPManager : NSObject

extern NSString * const MLXMPPDomain;
extern NSString * const MLXMPPHostName;

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoom *xmppRoom;
@property (nonatomic, strong) XMPPJID *xmppJid;
@property (nonatomic, assign) BOOL isXMPPConnected;
@property (nonatomic, assign) BOOL doRegisterAfterConnected;

@property (nonatomic, copy) void (^didReceiveMessage)(XMPPMessage  *message);
@property (nonatomic, copy) void (^loginSuccess)();

+ (instancetype)sharedManager;

- (void)connectThenLoginWith:(NSString *)user andPassword:(NSString *)password;
- (void)joinRoomWith:(NSString *)nickName toRoomJID:(XMPPJID *)jid;
- (void)sendToGroupWithMessage:(NSString *)message;



@end
