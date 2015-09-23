//
//  ViewController.h
//  SocketClient
//
//  Created by Hu Aihong on 15-8-21.
//  Copyright (c) 2015年 ChinaCloud. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@interface ViewController :UIViewController<UITextFieldDelegate>
{
    AsyncSocket *socket;
}
@property (retain, nonatomic) IBOutlet UITextField *serverIPAddress;
@property (retain, nonatomic) IBOutlet UITextView *ReceiveData;
@property (retain, nonatomic) IBOutlet UITextField *SendMessage;
@property (retain, nonatomic) IBOutlet UILabel *Status;

- (IBAction)Send:(id)sender;
- (IBAction)ConnectToSever:(id)sender;
@end

