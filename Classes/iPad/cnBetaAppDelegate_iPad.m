//
//  cnBetaAppDelegate.m
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import "cnBetaAppDelegate_iPad.h"
#import "RootController.h"
#import "DetailController.h"
#import "ASIHTTPRequest.h"

@implementation cnBetaAppDelegate_iPad

@synthesize window;
@synthesize splitController;

@synthesize rootController;
@synthesize detailController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch.	
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
    
    // Add the navigation controller's view to the window and display.
    [window addSubview:splitController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
		bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			//do something here
			[[UIApplication sharedApplication] endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		}];
	}
}


- (void)applicationWillEnterForeground:(UIApplication *)application{
	[[UIApplication sharedApplication] endBackgroundTask:bgTask];
	bgTask = UIBackgroundTaskInvalid;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[rootController release];
	[detailController release];
	[splitController release];
	[window release];
	[super dealloc];
}

+ (cnBetaAppDelegate_iPad *)instance{
	return (cnBetaAppDelegate_iPad *)[UIApplication sharedApplication].delegate;
}




@end

