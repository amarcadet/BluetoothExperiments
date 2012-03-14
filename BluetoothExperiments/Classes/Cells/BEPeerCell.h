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
	UILabel					*peerLabel;
	UIActivityIndicatorView *indicatorView;
}

@property (nonatomic, retain) IBOutlet UILabel *peerLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicatorView;

+ (NSString *)reuseIdentifier;

@end
