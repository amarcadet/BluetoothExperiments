//
//  BEPeerCell.h
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 14/03/12.
//  Copyright (c) 2012 SQLI Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BEPeerCell : UITableViewCell
{
	UILabel	*peerLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *peerLabel;

+ (NSString *)reuseIdentifier;

@end
