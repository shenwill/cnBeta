//
//  MGWeibo.m
//  iJokes
//
//  Created by Matthew Gao on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MGWeibo.h"
#import "JSON.h"
#import "OAMutableURLRequest.h"

@implementation NSObject (NSCoding)

-(id)initWithCoder:(NSCoder*)decoder {
    return [self init];
}

-(void)encodeWithCoder:(NSCoder*)encoder {	
}

@end

@implementation MGWeibo

@synthesize username = _username;
@synthesize password = _password;
@synthesize token = _token;
@synthesize secret = _secret;

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        self.username = [decoder decodeObjectForKey:@"username"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.token = [decoder decodeObjectForKey:@"token"];
        self.secret = [decoder decodeObjectForKey:@"secret"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.secret forKey:@"secret"];
}

+ (MGWeibo *)MGWeiboWithUsername:(NSString *)username Password:(NSString *)password Token:(NSString *)token{
    if ((username && password) || token) {
        MGWeibo *weibo = [[[MGWeibo alloc] init] autorelease];
        weibo.username = username;
        weibo.password = password;
        weibo.token = token;
        
        return weibo;
    }else{
        return nil;
    }
}

- (NSError *)xAuth{
    return [self xAuth:self.username Password:self.password];
}

- (NSError *)xAuth:(NSString *)username Password:(NSString *)password{ 
    NSString *url = @"http://api.t.sina.com.cn/oauth/access_token";
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:AppKey secret:AppSecret];
    OARequestParameter *source = [[OARequestParameter alloc] initWithName:@"source" value:AppKey];
    OARequestParameter *x_auth_mode = [[OARequestParameter alloc] initWithName:@"x_auth_mode" value:@"client_auth"];
    OARequestParameter *x_auth_password = [[OARequestParameter alloc] initWithName:@"x_auth_password" value:password];
    OARequestParameter *x_auth_username = [[OARequestParameter alloc] initWithName:@"x_auth_username" value:username];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] consumer:consumer token:nil realm:nil signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    [request setParameters:[NSArray arrayWithObjects:source, x_auth_mode, x_auth_password, x_auth_username, nil]];
    [request prepare];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    [request release];
    [consumer release];
    [source release];
    [x_auth_mode release];
    [x_auth_password release];
    [x_auth_username release];
    
    if (!data) {
        return [self responseError:nil];
    }
    
    NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
 
    if ([response rangeOfString:@"oauth_token"].location == NSNotFound) {
        return [NSError errorWithDomain:@"用户名或密码错误" code:403 userInfo:nil];
    }
    
    
    NSArray *strings = [response componentsSeparatedByString:@"&"];
    {
        NSString *string = [strings objectAtIndex:0];
        NSRange range = [string rangeOfString:@"oauth_token="];
        self.token = [string substringFromIndex:range.location + range.length];
    }
    {
        NSString *string = [strings objectAtIndex:1];
        NSRange range = [string rangeOfString:@"oauth_token_secret="];
        self.secret = [string substringFromIndex:range.location + range.length];
    }
    
    return nil;
}


#pragma mark -
- (NSError *)newTweet:(NSString *)content{
    NSString *url = @"http://api.t.sina.com.cn/statuses/update.json";
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:AppKey secret:AppSecret];
    OAToken *token = [[OAToken alloc] initWithKey:self.token secret:self.secret];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] consumer:consumer token:token realm:nil signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    
    OARequestParameter *param = [[OARequestParameter alloc] initWithName:@"status" value:[content URLEncodedString]];
    [request setParameters:[NSArray arrayWithObject:param]];
    
    [request prepare];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    [consumer release];
    [token release];
    [param release];
    [request release];
    
    if (!data) {
        return [[self responseError:nil] retain];
    }
    
    NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    return [[self responseError:response] retain];
}

- (NSError *)reTweet:(long long)ID Content:(NSString *)content{    
    NSString *url = @"http://api.t.sina.com.cn/statuses/repost.json";
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:AppKey secret:AppSecret];
    OAToken *token = [[OAToken alloc] initWithKey:self.token secret:self.secret];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] consumer:consumer token:token realm:nil signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
    
    OARequestParameter *sid = [[OARequestParameter alloc] initWithName:@"id" value:[NSString stringWithFormat:@"%lld", ID]];
    
    if ([content length]) {
        OARequestParameter *status = [[OARequestParameter alloc] initWithName:@"status" value:[content URLEncodedString]];
         [request setParameters:[NSArray arrayWithObjects:sid, status, nil]];
        [status release];
    }else{
        [request setParameters:[NSArray arrayWithObject:sid]];
    }
    
    [request prepare];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    [consumer release];
    [token release];
    [sid release];
    
    [request release];
    
    if (!data) {
        return [self responseError:nil];
    }
    
    NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    return [self responseError:response];

}

- (NSError *)responseError:(NSString *)response{
    if (!response) {
        return [NSError errorWithDomain:@"网络请求失败" code:-1 userInfo:nil];
    }
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:response];
    [parser release];
    
    if (!json) {
        return [NSError errorWithDomain:@"数据处理失败" code:500 userInfo:nil];
    }
    
    int errorCode = [[json objectForKey:@"error_code"] intValue];
    
    if (errorCode == 0) {
        return nil;
    }else if (errorCode == 403) {
        return [NSError errorWithDomain:@"用户名或密码错误" code:403 userInfo:nil];
    }else if(errorCode == 400){
        return [NSError errorWithDomain:@"不允许重复转发" code:400 userInfo:nil];
    }else{
        return [NSError errorWithDomain:[json objectForKey:@"error"] code:errorCode userInfo:nil];
    }
}

@end
