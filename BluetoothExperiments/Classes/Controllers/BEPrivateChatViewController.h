//
//  BEPrivateChatViewController.h
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 14/03/12.
//  Copyright (c) 2012 SQLI Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface BEPrivateChatViewController : UITableViewController

@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSString *peerID;

@end
