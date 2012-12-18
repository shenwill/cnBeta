//
//  RootViewController.m
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import "RootViewController.h"
#import "MGRssParser.h"
#import "ASIHTTPRequest.h"
#import "DetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "RssCell.h"

#define LightColor [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]
#define DarkColor [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]

@interface RootViewController (Private)

- (void)showLoading;
- (void)reloadTableViewDataSource;
- (void)dataSourceDidFinishLoadingNewData:(BOOL)isRefresh;

@end

@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = DarkColor;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
		self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo~iphone.png"]] autorelease];
	}else {
		self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]] autorelease];
	}
	
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	
	refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)] retain];
    refreshHeaderView.backgroundColor = DarkColor;//[UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    [self.tableView addSubview:refreshHeaderView];
    self.tableView.showsVerticalScrollIndicator = YES;
	
	dataArray = [[NSArray alloc] init];
	
	dataPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"data"];
	[dataPath retain];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if ([dataArray count] == 0) {	
		[self showLoading];
		
		NSData *data = [NSData dataWithContentsOfFile:dataPath];
		NSArray *items = [MGRssParser parseRssData:data];
		
		if (items) {
			dataArray = [[NSArray arrayWithArray:items] retain];
			[self.tableView reloadData];
		}
		
		[self performSelectorInBackground:@selector(checkData) withObject:nil];
	}
}


- (void)refresh{	
	[self performSelectorInBackground:@selector(checkData) withObject:nil];
}

- (void)checkData{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://www.cnbeta.com/api/getLatestTime.php"]];
	request.numberOfTimesToRetryOnTimeout = 2;
	request.shouldContinueWhenAppEntersBackground = YES;
	[request startSynchronous];
	
	NSError *error = [request error];
	lastTime = [[request responseString] retain];
	
	if (!error && ![lastTime isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"LastTime"]]) {
		//update
		[self performSelectorOnMainThread:@selector(fetchData:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
	}else {
		[self performSelectorOnMainThread:@selector(fetchData:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];		
	}
	
	[pool release];
}


- (void)fetchData:(NSNumber *)shouldRefresh{
	if ([shouldRefresh boolValue]) {
		//update
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://www.cnbeta.com/backend.php"]];
		request.numberOfTimesToRetryOnTimeout = 2;
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(requestDidFinished:)];
		[request setDidFailSelector:@selector(requestDidFailed:)];
		
		[request startAsynchronous];
	}else {
		//load local			
		[self dataSourceDidFinishLoadingNewData:NO];	
	}
}

- (void)requestDidFinished:(ASIHTTPRequest *)request{	
	NSData *data = [request responseData];
	
	if (data) {
		[data writeToFile:dataPath atomically:YES];
		
		[[NSUserDefaults standardUserDefaults] setObject:lastTime forKey:@"LastTime"];
		
		NSArray *array = [MGRssParser parseRssData:data];
		
		if (array) {
			dataArray = [NSArray arrayWithArray:array];
			[dataArray retain];
			
			[self.tableView reloadData];
			
			[self dataSourceDidFinishLoadingNewData:YES];
		}else {
			[self handleError:1];
		}

	}else {
		[self handleError:2];
	}

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)requestDidFailed:(ASIHTTPRequest *)request{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self handleError:3];
}

- (void)handleError:(int)code{
	NSString *message = nil;
	
	switch (code) {
		case 1:
			message = @"数据解析错误, 请稍后重试.";
			break;
		case 2:
			message = @"数据获取出错, 请稍后重试.";
			break;
		case 3:
			message = @"网络连接失败, 请稍后重试.";
			break;
		default:
			break;
	}
	
	if (message) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了" message:message delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[self dataSourceDidFinishLoadingNewData:NO];
}

- (NSString *)transLink:(NSString *)link{	
	NSScanner *scanner = [NSScanner scannerWithString:link];
	
	int location = [link rangeOfString:@"/" options:NSBackwardsSearch].location;
	NSString *result = nil;
	
	[scanner setScanLocation:location + 1];
	[scanner scanUpToString:@"." intoString:&result];
	
	return  result;
}

#pragma mark -
#pragma mark pull release tableview

- (void)showLoading{
	reloading = YES;
	
	[refreshHeaderView setState:EGOOPullRefreshLoading];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
	[UIView commitAnimations];
}

- (void)reloadTableViewDataSource{	
	[self performSelectorInBackground:@selector(checkData) withObject:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (scrollView.contentOffset.y <= - 65.0f && !reloading) {
		reloading = YES;
		[self reloadTableViewDataSource];
		[refreshHeaderView setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)dataSourceDidFinishLoadingNewData:(BOOL)isRefresh{
	reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	
	if (isRefresh) {
		[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


 // Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	// Return YES for supported orientations.
//	return YES;
//}
 


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 70.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RssCell";
    
    RssCell *cell = (RssCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RssCell" owner:self options:nil] objectAtIndex:0];//[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
	MGRssEntity *item = [dataArray objectAtIndex:indexPath.row];
	
//	cell.textLabel.text = item.title;
//	cell.detailTextLabel.text = item.pubDate;
//	
//	cell.textLabel.numberOfLines = 2;
	[cell setCellWithItem:item];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row % 2) {
		cell.backgroundColor = LightColor;
	}else {
		cell.backgroundColor = DarkColor;
	}

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	MGRssEntity *item = [dataArray objectAtIndex:indexPath.row];
	
	if (!controller) {
		controller = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
	}
	
    item.ID = [self transLink:item.link];
    
	controller.item = item;
	controller.shouldRefresh = YES;
	
	[self.navigationController pushViewController:controller animated:YES];	 
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[dataArray release];
}


- (void)dealloc {
	if (controller) {
		[controller release];
	}
    
    [refreshHeaderView release];
    [super dealloc];
}


@end

