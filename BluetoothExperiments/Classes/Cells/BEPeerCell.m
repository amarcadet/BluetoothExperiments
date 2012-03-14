//
//  BEPeerCell.m
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 14/03/12.
//  Copyright (c) 2012 SQLI Agency. All rights reserved.
//

#import "BEPeerCell.h"

@implementation BEPeerCell

@synthesize peerLabel;
@synthesize indicatorView;

- (void)dealloc
{
	[peerLabel release];
	
	[super dealloc];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	peerLabel.text = @"";
}

+ (NSString *)reuseIdentifier
{
	return NSStringFromClass([self class]);
}

@end
