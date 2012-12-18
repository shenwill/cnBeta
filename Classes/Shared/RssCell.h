//
//  RssCell.h
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGRssParser.h"

@interface RssCell : UITableViewCell {
	UILabel *contentLabel, *categoryLabel, *dateLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *contentLabel, *categoryLabel, *dateLabel;

- (void)setCellWithItem:(MGRssEntity *)item;

@end
