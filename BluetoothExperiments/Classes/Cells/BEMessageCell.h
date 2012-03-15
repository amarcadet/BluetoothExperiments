//
//  BEMessageCell.h
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 15/03/12.
//  Copyright (c) 2012 Epershand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BEMessageCell : UITableViewCell
{
	UILabel	*messageLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *messageLabel;

+ (NSString *)reuseIdentifier;

@end
