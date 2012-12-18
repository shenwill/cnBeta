//
//  WeiboViewController.m
//  iJokes
//
//  Created by Matthew Gao on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboViewController.h"
#import "MGWeibo.h"

@implementation WeiboViewController

@synthesize usernameField, passwordField;
@synthesize contentView;
@synthesize loadingView;
@synthesize nav;
@synthesize countLabel;

@synthesize content;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    contentView.layer.cornerRadius = 8.0;
	contentView.layer.masksToBounds = YES;
    contentView.text = self.content;
	
	self.nav.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)] autorelease];
	self.nav.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)] autorelease];
	
	[contentView becomeFirstResponder];
    
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"Weibo"];
    if (data) {
        weibo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        usernameField.text = weibo.username;
        passwordField.text = weibo.password;
    }else{
        weibo = [MGWeibo MGWeiboWithUsername:usernameField.text Password:passwordField.text Token:nil];
    }
    
    [weibo retain];
}

- (void)dismiss{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)send{
	if ([usernameField.text length] && [passwordField.text length]) {
		self.nav.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:loadingView] autorelease];
		
		[self performSelector:@selector(startRequest) withObject:nil afterDelay:0.1];
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了" message:@"请输入用户名密码" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

}

- (void)startRequest{
    if (!weibo.token || ![weibo.username isEqualToString:usernameField.text] || ![weibo.password isEqualToString:passwordField.text]) {
        weibo.username = usernameField.text;
        weibo.password = passwordField.text;
        
        NSError *error = [weibo xAuth];
        if (error) {
            [self showError:error];
            return;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:weibo] forKey:@"Weibo"];
        }
    }
    
    NSError *error = [weibo newTweet:contentView.text];
    if (!error) {
        [self dismiss];
    }else{
        if ([error code] == 403) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Weibo"];
            weibo.token = nil;
        }
        
        [self showError:error];
    }
}

- (void)showError:(NSError *)error{
    self.nav.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)] autorelease];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了" message:[error domain] delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)textViewDidChange:(UITextView *)textView{
	countLabel.text = [NSString stringWithFormat:@"%d", 140 - [textView.text length]];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[countLabel release];
	[nav release];
	[loadingView release];
	[usernameField release];
	[passwordField release];
	[contentView release];
    [super dealloc];
}


@end
