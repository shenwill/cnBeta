//
//  DetailViewController.m
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import "DetailViewController.h"
#import "ASIHTTPRequest.h"
#import "WebViewController.h"
#import "cnBetaAppDelegate_iPhone.h"
#import "HTMLParser.h"

@implementation DetailViewController

@synthesize item;
@synthesize shouldRefresh;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	if (shouldRefresh) {
		self.navigationItem.rightBarButtonItem = nil;		
		shouldRefresh = NO;
		
		if (mainView) {
            mainView.delegate = nil;
			[mainView removeFromSuperview];
			[mainView release];
			mainView = nil;
		}
		
    // the height was hard-coded as 416.0, it's the height of
    // self.view.frame.size for 3.5 inch display.
    // the width was 320.0.
		CGRect frame = CGRectMake(0.0, 0.0, self.view.frame.size.width,
                              self.view.frame.size.height);
		
		mainView = [[UIWebView alloc] initWithFrame:frame];
		mainView.delegate = self;
		mainView.dataDetectorTypes = UIDataDetectorTypeLink;
        mainView.backgroundColor = [UIColor whiteColor];
        
        for(UIImageView* imageView in [[[mainView subviews] lastObject] subviews]) {
            if(![imageView isKindOfClass:[UIImageView class]]) continue;
            imageView.hidden = YES;
        }
        
		[self.view addSubview:mainView];
		[self.view sendSubviewToBack:mainView];
		
        if (thread) {
            [thread release];
        }
        
        thread = [[[NSThread alloc] initWithTarget:self selector:@selector(fetchData) object:nil] retain];
        [thread start];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	if (mainView && [mainView isLoading]) {
		[mainView stopLoading];
	}
    
    if ([thread isFinished]) {
        [thread cancel];
    }
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
}


- (void)dealloc {
	if (mainView) {
        mainView.delegate = nil;
        [mainView release];
        mainView = nil;
	}
	
    [super dealloc];
}

#pragma mark -

- (void)fetchData{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    article = [[self parseArticle:self.item.ID] retain];
    
	// If article is nil, and comments not nil, commenta will be displayed with empty article content.
    // If article is nil, as well as comments, an alert will be shown.
    // if (article) {
        NSString *comment = [self parseComment:self.item.ID];
        if (comment) {
            [self performSelectorOnMainThread:@selector(didGetArticle:) withObject:[NSString stringWithFormat:@"%@<br />%@", article ? : @"", comment] waitUntilDone:NO];
        }else{
            [self performSelectorOnMainThread:@selector(didGetArticle:) withObject:article waitUntilDone:NO];
        }
        
    // }

    [pool release];
}

#pragma mark - 
- (NSString *)parseArticle:(NSString *)ID{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cnbeta.com/articles/%@.htm", ID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (!data) {
        return nil;
    }
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *string = [[NSString alloc] initWithData:data encoding:enc];
    NSError *error = nil;
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:string error:&error];
    [string release];
    
    if (error) {
        [parser release];
        return nil;
    }
    
    HTMLNode *body = [parser body];
    NSArray *divs = [body findChildTags:@"div"];
    
    NSMutableString *content = nil;
    
    for (HTMLNode *div in divs) {  
        if ([[div getAttributeNamed:@"id"] isEqualToString:@"news_content"]) {
            content = [NSMutableString stringWithCapacity:0];
            
            for (HTMLNode *child in [div children]) {
                if (![[child tagName] isEqualToString:@"a"]) {
                    [content appendString:[child rawContents]];
                }
            }
            
            break;
        }
    }
    
    [parser release];
    
    return content;    
}

- (NSString *)parseComment:(NSString *)ID{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.cnbeta.com/comment/normal/%@.html", ID]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (!data) {
        return nil;
    }
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [string autorelease];
}

- (void)didGetArticle:(NSString *)string{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (string) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(share)] autorelease];
        
        NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ArticleTemplate_iPhone" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{title}" withString:item.title];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{body}" withString:string];
        
        [mainView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.cnbeta.com"]];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了" message:@"获取文章内容出错, 请稍候重试." delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		WebViewController *controller = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
		controller.link = [[request URL] absoluteString];
		controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:controller animated:YES];
		[controller release];
		
		return NO;
	}else {
		return YES;
	}

}


- (void)share{
	if([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		controller.navigationBar.tintColor = [UIColor lightGrayColor];
		[controller setSubject:@"这篇新闻不错, 推荐你看看."];
		[controller setMessageBody:article isHTML:YES];
		[self presentModalViewController:controller animated:YES];
		[controller release];
	}else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了" message:@"您还没有设置邮件账户" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	[self dismissModalViewControllerAnimated:YES];
}


@end
