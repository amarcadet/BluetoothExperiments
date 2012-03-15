//
//  BEPrivateChatViewController.h
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 14/03/12.
//  Copyright (c) 2012 Epershand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface BEPrivateChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
	IBOutlet UITableView	*tableView;
	IBOutlet UIToolbar		*composeToolbar;
	IBOutlet UITextField	*textField;
}

@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSString *peerID;

@property (nonatomic, readonly) UITableView *tableView;

- (IBAction)sendAction:(id)sender;

@end
