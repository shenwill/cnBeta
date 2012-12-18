//
//  RssCell.m
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import "RssCell.h"


@implementation RssCell

@synthesize contentLabel, categoryLabel, dateLabel;


- (void)setCellWithItem:(MGRssEntity *)item{
	contentLabel.text = item.title;
	categoryLabel.text = item.category;
	dateLabel.text = item.pubDate;
}

- (void)dealloc {
	[contentLabel release];
	[categoryLabel release];
	[dateLabel release];
    [super dealloc];
}


@end
