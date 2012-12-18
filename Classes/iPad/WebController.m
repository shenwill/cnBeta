//
//  WebViewController.m
//  iJokes
//
//  Created by Matthew Gao on 9/12/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import "WebController.h"


@interface WebController ()

- (UIImage *)backArrow;
- (UIImage *)nextArrow;

@end


@implementation WebController

@synthesize mainView;
@synthesize goBackItem, goForwardItem, actionItem;

@synthesize link;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	if (link) {
		[mainView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]];
	}
}


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
 

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	if ([mainView isLoading]) {
		[mainView stopLoading];
	}
}


- (void)dealloc {
	[actionItem release];
	[goBackItem release];
	[goForwardItem release]; 
	[mainView release];
    [super dealloc];
}

#pragma mark -
- (IBAction)dismiss{
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)back{
	if ([mainView canGoBack]) {
		[mainView goBack];
	}
}


- (IBAction)next{
	if ([mainView canGoForward]) {
		[mainView goForward];
	}
}

- (IBAction)showAction{
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"用Safari打开" otherButtonTitles:nil];
	[menu showFromBarButtonItem:actionItem animated:YES];
	[menu release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
	}
}

#pragma mark -
- (UIImage *)backArrow{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,27,27,8,0,
												 colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	
	// set the fill color
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 8.0f, 13.0f);
	CGContextAddLineToPoint(context, 24.0f, 4.0f);
	CGContextAddLineToPoint(context, 24.0f, 22.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	// convert the context into a CGImageRef
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
    
    return image;
}

- (UIImage *)nextArrow{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil,27,27,8,0,
												 colorSpace,kCGImageAlphaPremultipliedLast);
	CFRelease(colorSpace);
	
	// set the fill color
	CGColorRef fillColor = [[UIColor blackColor] CGColor];
	CGContextSetFillColor(context, CGColorGetComponents(fillColor));
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 24.0f, 13.0f);
	CGContextAddLineToPoint(context, 8.0f, 4.0f);
	CGContextAddLineToPoint(context, 8.0f, 22.0f);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	// convert the context into a CGImageRef
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
    
    return image;
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	goForwardItem.enabled = [webView canGoForward];
	goBackItem.enabled = [webView canGoBack];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	goForwardItem.enabled = [webView canGoForward];
	goBackItem.enabled = [webView canGoBack];
}

@end
