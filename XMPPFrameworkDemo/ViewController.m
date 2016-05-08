//
//  ViewController.m
//  XMPPFrameworkDemo
//
//  Created by mjpc on 16/5/7.
//  Copyright © 2016年 mali. All rights reserved.
//

#import "ViewController.h"
#import "MLXMPPManager.h"

@interface ViewController () {
    UIButton *sendButton;
}

@end

@implementation ViewController

#pragma mark - ****************  LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configXMPP];
    [self configUI];
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

#pragma mark - ****************  Private M

- (void)configUI {
    if (!sendButton) {
        sendButton = [UIButton new];
        sendButton.frame = CGRectMake(200, 200, 100, 100);
        sendButton.backgroundColor = [UIColor blackColor];
        [sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sendButton];
    }
}

- (void)sendButtonClicked {
    NSString *message = @"你好，我是程序员";
    [[MLXMPPManager sharedManager] sendToGroupWithMessage:message];
}

@end
