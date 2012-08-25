//
//  OAuthTestViewController.m
//  DCTOAuthController
//
//  Created by Daniel Tull on 25.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "OAuthTestViewController.h"
#import <DCTOAuthController/DCTOAuthController.h>

@interface OAuthTestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *consumerKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *consumerSecretTextField;
@property (weak, nonatomic) IBOutlet UITextField *requestTokenURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *accessTokenURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorizeURLTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@end

@implementation OAuthTestViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (!self) return nil;
	
	self.title = @"DCTOAuthController";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Go" style:UIBarButtonItemStyleBordered target:self action:@selector(go:)];
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.consumerKeyTextField.text = @"key";
	self.consumerSecretTextField.text = @"secret";
	
	self.requestTokenURLTextField.text = @"http://term.ie/oauth/example/request_token.php";
	self.accessTokenURLTextField.text = @"http://term.ie/oauth/example/access_token.php";
}

- (IBAction)go:(id)sender {
	
	[self.consumerKeyTextField resignFirstResponder];
	[self.consumerSecretTextField resignFirstResponder];
	[self.requestTokenURLTextField resignFirstResponder];
	[self.accessTokenURLTextField resignFirstResponder];
	[self.authorizeURLTextField resignFirstResponder];
	self.resultTextView.text = nil;
	
	NSString *consumerKey = self.consumerKeyTextField.text;
	NSString *consumerSecret = self.consumerSecretTextField.text;
	
	NSURL *callbackURL = [NSURL URLWithString:@"oauthcallback://"];
	NSURL *requestTokenURL = [NSURL URLWithString:self.requestTokenURLTextField.text];
	NSURL *accessTokenURL = [NSURL URLWithString:self.accessTokenURLTextField.text];
	
	NSURL *authorizeURL = nil;
	NSString *authorizeURLString = self.authorizeURLTextField.text;
	if ([authorizeURLString length] > 0) authorizeURL = [NSURL URLWithString:authorizeURLString];
		
	DCTOAuthController *oauthController = [[DCTOAuthController alloc] initWithRequestTokenURL:requestTokenURL
																				 authorizeURL:authorizeURL
																				  callbackURL:callbackURL
																			   accessTokenURL:accessTokenURL
																				  consumerKey:consumerKey
																			   consumerSecret:consumerSecret];
	
	[oauthController performAuthenticationWithCompletion:^(NSDictionary *returnedValues) {
		
		NSMutableArray *textArray = [NSMutableArray new];
		[returnedValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[textArray addObject:[NSString stringWithFormat:@"%@ = \"%@\"", key, obj]];
		}];
		self.resultTextView.text = [textArray componentsJoinedByString:@"\n"];
	}];
}


@end
