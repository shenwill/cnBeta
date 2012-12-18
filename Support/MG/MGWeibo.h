//
//  MGWeibo.h
//  iJokes
//
//  Created by Matthew Gao on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AppKey @""
#define AppSecret @""

@interface NSObject (NSCoding)

-(id)initWithCoder:(NSCoder*)decoder;
-(void)encodeWithCoder:(NSCoder*)encoder;

@end

@interface MGWeibo : NSObject {
    NSString *_username, *_password;
    NSString *_token, *_secret;
}

@property (nonatomic, retain) NSString *username, *password;
@property (nonatomic, retain) NSString *token, *secret;

+ (MGWeibo *)MGWeiboWithUsername:(NSString *)username Password:(NSString *)password Token:(NSString *)token;

- (NSError *)newTweet:(NSString *)content;
- (NSError *)reTweet:(long long)ID Content:(NSString *)content;

- (NSError *)responseError:(NSString *)response;

- (NSError *)xAuth;
- (NSError *)xAuth:(NSString *)username Password:(NSString *)password;

@end
