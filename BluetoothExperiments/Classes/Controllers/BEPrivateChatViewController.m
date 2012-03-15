//
//  BEPrivateChatViewController.m
//  BluetoothExperiments
//
//  Created by Antoine Marcadet on 14/03/12.
//  Copyright (c) 2012 Epershand. All rights reserved.
//

#import "BEPrivateChatViewController.h"
#import "BEMessageCell.h"

@interface BEPrivateChatViewController ()
{
	GKSession			*_session;
	NSString			*_peerID;
	NSMutableArray		*_messages;
}

@property (nonatomic, retain) NSMutableArray *messages;

- (void)commonInit;
- (void)sendMessage:(NSString *)message;
- (void)receiveMessage:(NSString *)message;

@end


@implementation BEPrivateChatViewController

@synthesize session = _session;
@synthesize peerID = _peerID;
@synthesize messages = _messages;

@synthesize tableView;

#pragma mark - Memory management

- (void)dealloc
{
	if (tableView != nil)
	{
		[tableView release], tableView = nil;
	}
	
	if (tableView != nil)
	{
		[composeToolbar release], composeToolbar = nil;
	}
	
	if (tableView != nil)
	{
		[textField release], textField = nil;
	}
	
	self.messages = nil;
	
	[super dealloc];
}

- (void)commonInit
{
	self.messages = [NSMutableArray arrayWithCapacity:0];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self commonInit];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		[self commonInit];
	}
	return self;
}


#pragma mark - View management

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = [NSString stringWithFormat:@"Chat with %@", [self.session displayNameForPeer:self.peerID]];
	[self.session setDataReceiveHandler:self withContext:NULL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillAppear:) 
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillDisappear:)
												 name:UIKeyboardWillHideNotification 
											   object:nil];
	
	//[textField becomeFirstResponder];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.session setDataReceiveHandler:nil withContext:NULL];
	
	[tableView release], tableView = nil;
	[composeToolbar release], composeToolbar = nil;
	[textField release], textField = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Keyboard

- (void)keyboardWillAppear:(NSNotification *)notif
{
	NSDictionary *userInfo = [notif userInfo];
	
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	
	[UIView animateWithDuration:animationDuration
						  delay:.0 
						options:animationCurve
					 animations:^{
						 [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - keyboardFrame.size.height)];
					 } 
					 completion:NULL];
}

- (void)keyboardWillDisappear:(NSNotification *)notif
{	
	NSDictionary *userInfo = [notif userInfo];
	
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	
	[UIView animateWithDuration:animationDuration
						  delay:.0 
						options:animationCurve
					 animations:^{
						 [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + keyboardFrame.size.height)];
					 } 
					 completion:NULL];
}


#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)inTextField
{
	[self sendAction:inTextField];
	return YES;
}


#pragma mark - Internal

- (void)sendMessage:(NSString *)message
{
	NSLog(@"Sending message : %@", message);
	NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	[self.session sendData:data toPeers:[NSArray arrayWithObject:self.peerID] withDataMode:GKSendDataReliable error:&error];
	
	[self.messages addObject:[NSString stringWithFormat:@"Send : %@", message]];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
	[self.tableView endUpdates];
	
	[self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)receiveMessage:(NSString *)message
{
	NSLog(@"Receiving message : %@", message);
	[self.messages addObject:[NSString stringWithFormat:@"Receive : %@", message]];
	
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
	[self.tableView endUpdates];
	
	[self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - Session receiver

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
	NSLog(@"Receive Data from %@ (%@)", [session displayNameForPeer:peer], peer);
	[self receiveMessage:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
}


#pragma mark - Actions

- (IBAction)sendAction:(id)sender
{
	[self sendMessage:textField.text];
	textField.text = @"";
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)inTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BEMessageCell *cell = [inTableView dequeueReusableCellWithIdentifier:[BEMessageCell reuseIdentifier]];
    
	cell.messageLabel.text = [self.messages objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ([scrollView isDragging])
	{
		[textField resignFirstResponder];
	}
}

@end
