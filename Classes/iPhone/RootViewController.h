//
//  RootViewController.h
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController, EGORefreshTableHeaderView;

@interface RootViewController : UITableViewController {
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL reloading;
	
	NSArray *dataArray;
	NSString *dataPath, *lastTime;	
	
	DetailViewController *controller;
}

- (void)fetchData:(NSNumber *)shouldRefresh;
- (void)handleError:(int)code;
- (NSString *)transLink:(NSString *)link;

@end
