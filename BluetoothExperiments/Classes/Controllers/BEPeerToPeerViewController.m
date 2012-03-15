//
//  BEViewController.m
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 14/03/12.
//  Copyright (c) 2012 Epershand. All rights reserved.
//

#import "BEPeerToPeerViewController.h"
#import "BEPeerCell.h"
#import "EHAlertView.h"
#import "BEPrivateChatViewController.h"

@interface BEPeerToPeerViewController () <GKSessionDelegate>
{
	GKSession	*_session;
	NSString	*_connectingPeer;
	NSString	*_connectedPeer;
}

@property (nonatomic, retain) GKSession *session;
@property (nonatomic, retain) NSString *connectingPeer;
@property (nonatomic, retain) NSString *connectedPeer;

- (void)startSession;
- (void)stopSession;

@end


@implementation BEPeerToPeerViewController

@synthesize session = _session;
@synthesize connectingPeer = _connectingPeer;
@synthesize connectedPeer = _connectedPeer;

- (void)dealloc
{
	[self stopSession];
	
	self.connectingPeer = nil;
	self.connectedPeer = nil;
	
	[super dealloc];
}


#pragma mark - View management

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self startSession];
}

- (void)viewDidUnload
{
	[self stopSession];
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"chatSegue"])
	{
		BEPrivateChatViewController *privateController = (BEPrivateChatViewController *)segue.destinationViewController;
		privateController.session = self.session;
		privateController.peerID = (NSString *)sender;
	}
}


#pragma mark - Internals

- (void)startSession
{
	self.session = [[[GKSession alloc] initWithSessionID:@"iChat" 
											 displayName:[[UIDevice currentDevice] name]
											 sessionMode:GKSessionModePeer] autorelease];
	//[self.session setDataReceiveHandler:<#(id)#> withContext:<#(void *)#>];
	self.session.disconnectTimeout = 10.0;
	self.session.delegate = self;
	self.session.available = YES;
	
	NSLog(@"Start session");
}

- (void)stopSession
{
	NSLog(@"Stop session");
	
	self.session.available = NO;
	self.session.delegate = nil;
	[self.session disconnectFromAllPeers];
	self.session = nil;
}


#pragma mark - Session delegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	NSLog(@"Peer change state : %@ (%@)", [session displayNameForPeer:peerID], peerID);
	
	// if the peerID that update his state is the one that we to connect and the state is connected, we can push the chat controller
	if ([peerID isEqualToString:self.connectingPeer] && state == GKPeerStateConnected)
	{
		NSLog(@"Connected to %@", [session displayNameForPeer:peerID]);
		self.connectedPeer = self.connectingPeer;
		self.connectingPeer = nil;
		[self performSegueWithIdentifier:@"chatSegue" sender:peerID];
	}
	
	[self.tableView reloadData];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	NSLog(@"Fail to connect with peer %@ (%@) : %@", [session displayNameForPeer:peerID], peerID, error);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	NSLog(@"Connection request from : %@ (%@)", [session displayNameForPeer:peerID], peerID);
	
	EHAlertView *alertView = [[EHAlertView alloc] initWithTitle:@"Connection request"
														message:[NSString stringWithFormat:@"%@ would like to chat with you", [session displayNameForPeer:peerID]]
											  cancelButtonTitle:@"Ignore" 
											  otherButtonTitles:@"Accept", nil];
	[alertView setClickedButtonBlock:^(NSInteger buttonIndex) {
		if (buttonIndex == 1)
		{
			[session acceptConnectionFromPeer:peerID error:NULL];
			[self performSegueWithIdentifier:@"chatSegue" sender:peerID];
		}
		else
		{
			[session denyConnectionFromPeer:peerID];
		}
	}];
	[alertView show];
	[alertView release];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"Fail : %@", error);
}


#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if 0
	GKPeerStateAvailable,    // not connected to session, but available for connectToPeer:withTimeout:
	GKPeerStateUnavailable,  // no longer available
	GKPeerStateConnected,    // connected to the session
	GKPeerStateDisconnected, // disconnected from the session
	GKPeerStateConnecting,   // waiting for accept, or deny response
#endif
	
	NSMutableArray *allPeers = [NSMutableArray arrayWithCapacity:0];
	
	NSArray *availablePeers = [self.session peersWithConnectionState:GKPeerStateAvailable];
	[allPeers addObjectsFromArray:availablePeers];
	
	NSArray *connectedPeers = [self.session peersWithConnectionState:GKPeerStateConnected];
	[allPeers addObjectsFromArray:connectedPeers];
	
	NSArray *connectingPeers = [self.session peersWithConnectionState:GKPeerStateConnecting];
	[allPeers addObjectsFromArray:connectingPeers];
	
	return [allPeers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BEPeerCell *cell = [tableView dequeueReusableCellWithIdentifier:[BEPeerCell reuseIdentifier]];
	
	NSMutableArray *allPeers = [NSMutableArray arrayWithCapacity:0];
	
	NSArray *availablePeers = [self.session peersWithConnectionState:GKPeerStateAvailable];
	[allPeers addObjectsFromArray:availablePeers];
	
	NSArray *connectedPeers = [self.session peersWithConnectionState:GKPeerStateConnected];
	[allPeers addObjectsFromArray:connectedPeers];
	
	NSArray *connectingPeers = [self.session peersWithConnectionState:GKPeerStateConnecting];
	[allPeers addObjectsFromArray:connectingPeers];
	
	NSString *peerID = [allPeers objectAtIndex:indexPath.row];
	
	if ([availablePeers containsObject:peerID])
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if ([connectedPeers containsObject:peerID])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else if ([connectingPeers containsObject:peerID])
	{
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		indicator.hidesWhenStopped = YES;
		[indicator startAnimating];
		
		cell.accessoryView = indicator;
		[indicator release];
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	cell.peerLabel.text = [NSString stringWithFormat:@"%@ (%@)", [self.session displayNameForPeer:peerID], peerID];
	
	return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *allPeers = [NSMutableArray arrayWithCapacity:0];
	
	NSArray *availablePeers = [self.session peersWithConnectionState:GKPeerStateAvailable];
	[allPeers addObjectsFromArray:availablePeers];

	NSArray *connectedPeers = [self.session peersWithConnectionState:GKPeerStateConnected];
	[allPeers addObjectsFromArray:connectedPeers];
	
	NSArray *connectingPeers = [self.session peersWithConnectionState:GKPeerStateConnecting];
	[allPeers addObjectsFromArray:connectingPeers];
	
	NSString *peerID = [allPeers objectAtIndex:indexPath.row];
	
	if ([peerID isEqualToString:self.connectedPeer])
	{
		[self performSegueWithIdentifier:@"chatSegue" sender:peerID];
		return;
	}
	
	if ([availablePeers containsObject:peerID])
	{
		// if we had a previous connection in progress we have to stop it
		if (self.connectingPeer != nil)
		{
			[self.session cancelConnectToPeer:self.connectingPeer];
			self.connectingPeer = nil;
		}
	
		self.connectingPeer = peerID;
		
		// trying to connect to the selected peer
		[self.session connectToPeer:self.connectingPeer withTimeout:20.0];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

@end
