//
//  MGRssParser.m
//  cnBeta
//
//  Created by Matthew Gao on 9/27/10.
//  Copyright 2010 Matthew Gao. All rights reserved.
//

#import "MGRssParser.h"
#import "TouchXML.h"
#import "cnBetaAppDelegate_iPhone.h"

@implementation MGRssEntity

@synthesize title, link, category, description, pubDate, ID;

@end


@implementation MGRssParser


+ (NSArray *)parseRssData:(NSData *)data{	
	NSError *error = nil;
	
	CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithData:data encoding:NSUTF8StringEncoding options:0 error:&error] autorelease];
	
	if (error) {
		return nil;
	}
	
    NSArray *resultNodes = nil;
	
    resultNodes = [rssParser nodesForXPath:@"//item" error:&error];
	
	NSMutableArray *rssArray = [[NSMutableArray alloc] init];
	
    for (CXMLElement *resultElement in resultNodes) {
        NSMutableDictionary *blogItem = [[NSMutableDictionary alloc] init];
		
        int counter;
		
        for(counter = 0; counter < [resultElement childCount]; counter++) {
			
			NSString *key = [[resultElement childAtIndex:counter] name];
			NSString *value = [[resultElement childAtIndex:counter] stringValue];
			if(value == nil){
				value = @"";
			}
			
            [blogItem setObject:value forKey:key];
        }
		
		MGRssEntity *item = [[MGRssEntity alloc] init];
		
		item.title = [blogItem objectForKey:@"title"];
		item.description = [blogItem objectForKey:@"description"];
		item.link = [blogItem objectForKey:@"link"];
		item.pubDate = [MGRssParser formatDate:[blogItem objectForKey:@"pubDate"]];
		item.category = [blogItem objectForKey:@"category"];
		
        [rssArray addObject:item];	
		
		[item release];
		[blogItem release];
    }
	
	return [NSArray arrayWithArray:[rssArray autorelease]];
}

+ (NSString *)formatDate:(NSString *)date{
	if (date == nil) {
		return @"未知日期";
	}
	
	//	Sat May 01 15:42:05 +0800 2010
	//	EEE MMM d HH:mm:ss ZZZZ yyyy
	
	//Fri, 07 May 2010 13:19:32 GMT
	//Mon, 21 Jun 2010 08:44:40 GMT
	
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[inputFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss 'GMT'"];
	NSDate *formatterDate = [inputFormatter dateFromString:date];
    [inputFormatter release];
	
	if (formatterDate == nil) {
		return date;
	}
	
	NSString *newDateString = nil;
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"MM月dd日 HH:mm"];
	[outputFormatter setTimeZone:[NSTimeZone localTimeZone]];
	newDateString = [outputFormatter stringFromDate:formatterDate];
	
	[outputFormatter release];
	
	return newDateString;
}

@end
