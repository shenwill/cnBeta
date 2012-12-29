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

@interface DetailViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate>{
    UIWebView *mainView;
    NSThread *thread;
    
	MGRssEntity *item;
    NSString *article;
    
	BOOL shouldRefresh;	
}

@property (nonatomic, retain) MGRssEntity *item;
@property BOOL shouldRefresh;

- (NSString *)parseArticle:(NSString *)ID;
- (NSString *)parseComment:(NSString *)ID;
- (void)didGetArticle:(NSString *)string;

@end
