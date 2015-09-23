//
//  ViewController.m
//  SocketClient
//
//  Created by Hu Aihong on 15-8-21.
//  Copyright (c) 2015年 ChinaCloud. All rights reserved.
//

#import "ViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    _serverIPAddress.delegate=self;
    [_serverIPAddress setTag:1];
    _SendMessage.delegate=self;
    [_SendMessage setTag:2];
    _ReceiveData.editable=NO;
   
    // Do any additional setup after loading the view, typically from a nib.
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField tag]==2)
    {
        [self viewUp];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    
    [textField resignFirstResponder];
    if([textField tag]==2)
    {
        [self viewDown];
    }
    return YES;
}

//click the space screen,then keyboard disappear
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [_SendMessage resignFirstResponder];
    [_serverIPAddress resignFirstResponder];
     [self viewDown];
    
    
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationPortrait;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
- (IBAction)Send:(id)sender {
    if(![_SendMessage.text isEqualToString:@""] && ![_serverIPAddress.text isEqualToString:@""])
    {
        NSString *message=[NSString stringWithFormat:@"%@:%@",[self getIPAddress],_SendMessage.text];;
        if(socket==nil)
        {
            socket=[[AsyncSocket alloc]initWithDelegate:self];
        }
        //NSString *content=[message stringByAppendingString:@"\r\n"];
        [socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding]withTimeout:-1 tag:0];
        _ReceiveData.text=[NSString stringWithFormat:@"me:%@",_SendMessage.text];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Waring"message:@"Please input Message!"delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alert show];
        
    }
}


- (IBAction)ConnectToSever:(id)sender {
    if(socket==nil)
    {
        socket=[[AsyncSocket alloc]initWithDelegate:self];
        NSError *error=nil;
        if(![socket connectToHost:_serverIPAddress.text onPort:8080 error:&error])
        {
            _Status.text=@"Connect Failed!";
        }
        else
        {
            _Status.text=@"Connected!";
        }
    }
    else
    {
        _Status.text=@"Connected!";
    }
}

#pragma AsyncScoket Delagate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu",sock,host,port);
    [sock readDataWithTimeout:1 tag:0];
}
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout: -1 tag: 0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* aStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.ReceiveData.text =[NSString stringWithFormat:@"%@:%@",_serverIPAddress.text,aStr];
   
    [socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
    NSString *msg =@"Sorry this connect is failure";
    _Status.text=msg;
   
    socket = nil;
}
- (void) viewUp
{
    CGRect frame=self.view.frame;
    frame.origin.y=frame.origin.y-215;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame=frame;
    [UIView commitAnimations];
}
- (void) viewDown
{
    CGRect frame=self.view.frame;
    frame.origin.y=frame.origin.y+215;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.view.frame=frame;
    [UIView commitAnimations];
}

@end
