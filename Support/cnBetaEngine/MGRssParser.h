//
//  MGRssParser.h
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGRssEntity : NSObject{
	NSString *title, *link, *category, *description, *pubDate, *ID;
}

@property (nonatomic, retain) NSString *title, *link, *category, *description, *pubDate, *ID;

@end


@interface MGRssParser : NSObject {

}

+ (NSArray *)parseRssData:(NSData *)data;
+ (NSString *)formatDate:(NSString *)date;

@end
