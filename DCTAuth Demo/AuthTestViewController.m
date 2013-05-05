//
//  AuthTestViewController.m
//  DCTAuth
//
//  Created by Daniel Tull on 25.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "AuthTestViewController.h"
#import <DCTAuth/DCTAuth.h>

@interface AuthTestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *consumerKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *consumerSecretTextField;
@property (weak, nonatomic) IBOutlet UITextField *requestTokenURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *accessTokenURLTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorizeURLTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@end

@implementation AuthTestViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (!self) return nil;
	
	self.title = @"DCTAuth";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Go" style:UIBarButtonItemStyleDone target:self action:@selector(go:)];
	
	UIBarButtonItem *load = [[UIBarButtonItem alloc] initWithTitle:@"Load" style:UIBarButtonItemStyleBordered target:self action:@selector(go:)];
	UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(go:)];
	self.navigationItem.leftBarButtonItems = @[load, save];
	
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
	
	UITextField *consumerKeyTextField = self.consumerKeyTextField;
	UITextField *consumerSecretTextField = self.consumerSecretTextField;
	UITextField *requestTokenURLTextField = self.requestTokenURLTextField;
	UITextField *accessTokenURLTextField = self.accessTokenURLTextField;
	UITextField *authorizeURLTextField = self.authorizeURLTextField;
	
	[consumerKeyTextField resignFirstResponder];
	[consumerSecretTextField resignFirstResponder];
	[requestTokenURLTextField resignFirstResponder];
	[accessTokenURLTextField resignFirstResponder];
	[authorizeURLTextField resignFirstResponder];
	self.resultTextView.text = nil;
	
	NSString *consumerKey = consumerKeyTextField.text;
	NSString *consumerSecret = consumerSecretTextField.text;
	
	NSURL *requestTokenURL = [NSURL URLWithString:requestTokenURLTextField.text];
	NSURL *accessTokenURL = [NSURL URLWithString:accessTokenURLTextField.text];
	
	NSURL *authorizeURL = nil;
	NSString *authorizeURLString = authorizeURLTextField.text;
	if ([authorizeURLString length] > 0) authorizeURL = [NSURL URLWithString:authorizeURLString];
	
	DCTAuthAccount *oauthAccount = [DCTAuthAccount OAuthAccountWithType:@"term.ie"
														requestTokenURL:requestTokenURL
														   authorizeURL:authorizeURL
														 accessTokenURL:accessTokenURL
															consumerKey:consumerKey
														 consumerSecret:consumerSecret];
	
	[oauthAccount authenticateWithHandler:^(NSArray *responses, NSError *error) {

		[[DCTAuthAccountStore defaultAccountStore] saveAccount:oauthAccount];

		NSMutableArray *textArray = [NSMutableArray new];
		[responses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[textArray addObject:[NSString stringWithFormat:@"%@\n", obj]];
		}];
		self.resultTextView.text = [textArray componentsJoinedByString:@"\n"];
		NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), oauthAccount);
	}];
}


@end
