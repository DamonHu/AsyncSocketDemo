//
//  ViewController.h
//  AsyncSocketDemo
//
//  Created by Damon on 16/8/30.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h" // for TCP
#import "GCDAsyncUdpSocket.h" // for UDP

@interface ViewController : UIViewController <GCDAsyncSocketDelegate>

@property(strong,nonatomic)NSMutableArray *mySocketArray;
@property(strong,nonatomic)GCDAsyncSocket *myTcpSocket;
@property(strong,nonatomic)NSTimer  *mytime;
@end

