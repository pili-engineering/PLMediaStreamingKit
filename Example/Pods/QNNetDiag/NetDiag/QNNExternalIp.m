//
//  QNNExternalIp.m
//  NetDiag
//
//  Created by bailong on 16/1/26.
//  Copyright © 2016年 Qiniu Cloud Storage. All rights reserved.
//

#import "QNNExternalIp.h"

@implementation QNNExternalIp

+ (NSString *)externalIp {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://whatismyip.akamai.com"]];
    [urlRequest setHTTPMethod:@"GET"];

    NSHTTPURLResponse *response = nil;
    NSError *httpError = nil;
    NSData *d = [NSURLConnection sendSynchronousRequest:urlRequest
                                      returningResponse:&response
                                                  error:&httpError];
    if (httpError != nil || d == nil) {
        return @"";
    }
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    if (s == nil) {
        return @"";
    }
    return s;
}

+ (NSString *)externalDNS {
    return @"";
}

+ (NSString *)getDiagUrl {
    NSString *fetchurl = @"http://ns.pbt.cachecn.net/fast_tools/fetch_ldns_diag_client.php";

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:fetchurl]];
    [urlRequest setHTTPMethod:@"GET"];

    NSHTTPURLResponse *response = nil;
    NSError *httpError = nil;
    NSData *d = [NSURLConnection sendSynchronousRequest:urlRequest
                                      returningResponse:&response
                                                  error:&httpError];
    if (httpError != nil || d == nil) {
        NSLog(@"fetch http error %@", httpError);
        return nil;
    }
    NSLog(@"fetch http code %ld", (long)response.statusCode);
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    if (s == nil || [s isEqualToString:@""]) {
        NSLog(@"fetch http code %ld", (long)response.statusCode);
        return nil;
    }
    NSRange range = [s rangeOfString:@"<iframe src=\""];
    if (range.location > 4000) {
        return nil;
    }
    s = [s substringFromIndex:range.location + range.length];
    range = [s rangeOfString:@".php\""];
    if (range.location > 4000) {
        return nil;
    }
    s = [s substringToIndex:range.location + 4];
    return s;
}

// this service provided by fastweb
//<pre>
//<table border="0" cellpadding="0" cellspacing="0" class="dns">
//<tr>
//<th>您的IP：</th>
//<td width="128" >60.168.142.119</td>
//<td>电信_安徽省_合肥市</td>
//</tr>
//<tr>
//<th>您的DNS：</th>
//<td width="128" >61.132.161.9</td>
//<td>电信_安徽省_阜阳市</td>
//</tr>
//</table>
//</pre>
//<p class="result">您的DNS配置正确！ </p>

+ (NSString *)checkExternal {
    NSString *url = [QNNExternalIp getDiagUrl];
    if (url == nil) {
        return @"get fetch url failed";
    }

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [urlRequest setHTTPMethod:@"GET"];

    NSHTTPURLResponse *response = nil;
    NSError *httpError = nil;
    NSData *d = [NSURLConnection sendSynchronousRequest:urlRequest
                                      returningResponse:&response
                                                  error:&httpError];
    if (httpError != nil || d == nil) {
        return @"check server error";
    }
    NSLog(@"http code %ld", (long)response.statusCode);
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    if (s == nil || [s isEqualToString:@""]) {
        return @"invalid encoding";
    }

    NSRange range = [s rangeOfString:@"<tr>"];
    s = [s substringFromIndex:range.location + range.length];
    range = [s rangeOfString:@"</table>"];
    s = [s substringToIndex:range.location];

    s = [s stringByReplacingOccurrencesOfString:@"</" withString:@"<"];

    s = [s stringByReplacingOccurrencesOfString:@"<tr>" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<th>" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<td width=\"128\" >" withString:@""];

    s = [s stringByReplacingOccurrencesOfString:@"<table>" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<p class=\"result\">" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<pre>" withString:@""];
    s = [s stringByReplacingOccurrencesOfString:@"<p>" withString:@""];

    s = [s stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return s;
}

@end
