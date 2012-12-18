//
//  cnBetaAppDelegate.h
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootController, DetailController;

@interface cnBetaAppDelegate_iPad : NSObject <UIApplicationDelegate, UISplitViewControllerDelegate> {
    UIWindow *window;
	UISplitViewController *splitController;
	
	RootController *rootController;
	DetailController *detailController;	
	
	UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitController;

@property (nonatomic, retain) IBOutlet RootController *rootController;
@property (nonatomic, retain) IBOutlet DetailController *detailController;

+ (cnBetaAppDelegate_iPad *)instance;

@end

