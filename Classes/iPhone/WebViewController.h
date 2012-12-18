//
//  WebViewController.h
//  iJokes
//
//  Created by Matthew Gao on 9/12/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>{
	UIWebView *mainView;
	UIBarButtonItem *goBackItem, *goForwardItem;
	
	NSString *link;
}

@property (nonatomic, retain) IBOutlet UIWebView *mainView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goBackItem, *goForwardItem;

@property (nonatomic, retain) NSString *link;

- (IBAction)dismiss;
- (IBAction)back;
- (IBAction)next;
- (IBAction)showAction;

@end
