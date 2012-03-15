//
//  BEMessageCell.m
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 15/03/12.
//  Copyright (c) 2012 Epershand. All rights reserved.
//

#import "BEMessageCell.h"

@implementation BEMessageCell

@synthesize messageLabel;

- (void)dealloc
{
	[messageLabel release];
	
	[super dealloc];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	messageLabel.text = @"";
}

+ (NSString *)reuseIdentifier
{
	return NSStringFromClass([self class]);
}

@end
