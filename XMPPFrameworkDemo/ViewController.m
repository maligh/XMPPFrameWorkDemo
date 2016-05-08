//
//  ViewController.m
//  XMPPFrameworkDemo
//
//  Created by mjpc on 16/5/7.
//  Copyright © 2016年 mali. All rights reserved.
//

#import "ViewController.h"
#import "MLXMPPManager.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - ****************  LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configXMPP];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - ****************  XMPP

- (void)configXMPP {
    __weak typeof(self)weakSelf = self;
    [MLXMPPManager sharedManager].didReceiveMessage = ^(XMPPMessage  *message){[weakSelf onReceiveMessage:message];};
    
    [MLXMPPManager sharedManager].loginSuccess = ^(NSString *str){[weakSelf loginSucessXMPP];};
    [[MLXMPPManager sharedManager] connectThenLoginWith:@"test" andPassword:@"111111"];
}


/** TODO:登录成功后加入聊天室*/
-(void)loginSucessXMPP {
    XMPPJID *roomJID = [XMPPJID jidWithString:@"jianshu@conference.localhost"];
    [[MLXMPPManager sharedManager] joinRoomWith:@"test" toRoomJID:roomJID];
}

/** TODO:收到消息*/
- (void) onReceiveMessage:(XMPPMessage  *)message {
    NSString *content = [[message elementForName:@"body"] stringValue];
    NSLog(@"你收到了群聊消息:%@",content);
}

#pragma mark - ****************  Private Methods

- (void)sendButtonClicked {
    NSString *message = @"你好，我是程序员";
    [[MLXMPPManager sharedManager] sendToGroupWithMessage:message];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self sendButtonClicked];
}

@end
