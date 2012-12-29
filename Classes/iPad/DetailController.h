//
//  DetailViewController.h
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MGRssParser.h"


@interface DetailController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, UISplitViewControllerDelegate, UIPopoverControllerDelegate>{
	UIWebView *mainView;
	UINavigationItem *navItem;
	UIPopoverController *popoverController;
	UIBarButtonItem *detailItem;
    
    NSThread *thread;
	
	MGRssEntity *item;
	NSString *article;
}

@property (nonatomic, retain) IBOutlet UIWebView *mainView;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) MGRssEntity *item;

- (void)refresh;
- (NSString *)parseArticle:(NSString *)ID;
- (NSString *)parseComment:(NSString *)ID;
- (void)didGetArticle:(NSString *)string;

@end
