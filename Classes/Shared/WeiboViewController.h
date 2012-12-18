//
//  WeiboViewController.h
//  iJokes
//
//  Created by Matthew Gao on 11/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MGWeibo.h"

@interface WeiboViewController : UIViewController <UITextViewDelegate>{
	UITextField *usernameField, *passwordField;
	UITextView *contentView;
	UIActivityIndicatorView *loadingView;
	UINavigationItem *nav;
	UILabel *countLabel;
	
	NSString *content;
    
    MGWeibo *weibo;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField, *passwordField;
@property (nonatomic, retain) IBOutlet UITextView *contentView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) IBOutlet UINavigationItem *nav;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;

@property (nonatomic, retain) NSString *content;

- (void)showError:(NSError *)error;

@end
