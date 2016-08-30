//
//  ViewController.m
//  AsyncSocketDemo
//
//  Created by Damon on 16/8/30.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

enum{
    SOCKET_OFFLINE_SERVER = -2,//服务器断开
    SOCKET_OFFLINE_USER,       //用户主动断开
};

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mySocketArray =[[NSMutableArray alloc] init];
    //可以使用自动布局
    UIEdgeInsets padding = UIEdgeInsetsMake(50, 50, 10, -50);
    UIButton *button = [[UIButton alloc] init];
    [self.view addSubview:button];
    [button setTag:1];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top);
        make.left.equalTo(self.view.mas_left).with.offset(padding.left);
    }];
    [button setTitle:@"TCP测试" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tcpTest:) forControlEvents:UIControlEventTouchUpInside];
   
    
    UIButton *button2 = [[UIButton alloc] init];
    [self.view addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top);
        make.right.equalTo(self.view.mas_right).with.offset(padding.right);
    }];
    [button2 setTitle:@"UDP测试" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(udpTest:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [[UIButton alloc] init];
    [button setTag:2];
    [self.view addSubview:button3];
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top+50);
        make.left.equalTo(self.view.mas_left).with.offset(padding.left);
    }];
    [button3 setTitle:@"TCP测试2" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(tcpOtherTest:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button4 = [[UIButton alloc] init];
    [self.view addSubview:button4];
    [button4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(padding.top+50);
        make.right.equalTo(self.view.mas_right).with.offset(padding.right);
    }];
    [button4 setTitle:@"断开连接" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(disConnectSocket) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tcpTest:(UIButton*)sender
{
    NSLog(@"tcpTest");
    self.myTcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self tcpConnetwithData:[NSString stringWithFormat:@"%d",(int)sender.tag]];
    [self.mySocketArray addObject: self.myTcpSocket];
}

-(void)tcpOtherTest:(UIButton*)sender
{
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [socket setUserData:[NSString stringWithFormat:@"%d",(int)sender.tag]];
    [self.mySocketArray addObject:socket];
    
    NSError *error = nil;
    if (![socket connectToHost:@"hudongdong.com" onPort:80 withTimeout:2 error:&error]) {
        NSLog(@"error:%@",error);
    }
}

-(void)udpTest:(UIButton*)sender
{
    NSLog(@"udpTest");
    
}

-(void)disConnectSocket
{
    for (GCDAsyncSocket *socket in self.mySocketArray) {
        socket.userData = [NSString stringWithFormat:@"%d",SOCKET_OFFLINE_USER];
        [self.mytime invalidate];   //停止心跳包发送
        [socket disconnect];    //断开链接
    }
    
}

-(void)tcpConnetwithData:(NSString*)userData
{
    [self.myTcpSocket setUserData:userData];
    
    NSError *error = nil;
    if (![ self.myTcpSocket connectToHost:@"hudongdong.com" onPort:80 withTimeout:2.0f error:&error]) {
        NSLog(@"error:%@",error);
    }
}

//发送心跳包
-(void)heartbeatFunc
{
    //心跳包的内容是前后端自定义的
    NSString *heart = @"Damon";
    NSData *data= [heart dataUsingEncoding:NSUTF8StringEncoding];
    [self.myTcpSocket writeData:data withTimeout:10.0f tag:0];
}

//发送数据
-(void)sendData
{
    NSString *dataStr = @"Damon_Hu";
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.myTcpSocket writeData:data withTimeout:10.0f tag:1];
    
    NSString *dataStr2 = @"Damon_Hu2";
    NSData *data2 = [dataStr2 dataUsingEncoding:NSUTF8StringEncoding];
    [self.myTcpSocket writeData:data2 withTimeout:10.0f tag:2];
}
//接受数据
-(void)reciveData:(NSData*)data
{
    //接收到的数据写入本地
    NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
}

#pragma mark  GCDAsyncSocketDelegate
//连接
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"didConnectToHost");
    //连上之后可以每隔30s发送一次心跳包
    self.mytime =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(heartbeatFunc) userInfo:nil repeats:YES];
    [self.mytime fire];
}

//断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    NSLog(@"socketDidDisconnect");
    //主动断开
    if ([sock.userData isEqualToString:[NSString stringWithFormat:@"%d",SOCKET_OFFLINE_USER]]) {
        return;
    }
    else{
        NSLog(@"%@",err);
        //断线重连
        [self tcpConnetwithData:@"1"];
    }
}

//多链接
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"userData:%@",[newSocket userData]);
}

//向服务器发送完数据之后回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"have send");
    if (tag == 1) {
        NSLog(@"first send");
    }
    else if (tag ==2){
        NSLog(@"second send");
    }
}

//本地接收到数据之后回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.myTcpSocket readDataWithTimeout:10.0f tag:tag];
    //接受到数据之后写入本地
    [self reciveData:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
