//
//  Utils.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 8/11/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "Utils.h"
#import "CryptLib.h"
#import "NSData+Base64.h"

NSDictionary *config;
NSString *key = @"1bf6bf65e45b55825b1919cbadd028e6";
NSString *iv = @"_sbSmKUxVQAQ-hvQ";

@implementation Utils

static const int ddLogLevel = DDLogLevelVerbose;

+ (void) init {
     
     [self loadConfigurations];
     
     LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
     [logglyLogger setLogFormatter:[[LogglyFormatter alloc] init]];
     logglyLogger.logglyKey = [self decrypt:[Utils getConfigurationForKey:@"logglyToken"]];
     
          // Set posting interval every 15 seconds, just for testing this out, but the default value of 600 seconds is better in apps
          // that normally don't access the network very often. When the user suspends the app, the logs will always be posted.
     
     logglyLogger.saveInterval = 5;
     logglyLogger.logglyTags = @"ios";
     
     [DDLog addLogger:logglyLogger];
}

+ (void)logString:(NSString *)message forObjects:(NSArray *)objects forLevel:(NSString *)level {
     if (objects != nil) {
          NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objects options:nil error:nil];
          NSString* string = [NSString stringWithUTF8String:[jsonData bytes]].description;
          NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
          [dictionary setObject:message forKey:@"message"];
          [dictionary setObject:string forKey:@"objects"];
          [dictionary setObject:level forKey:@"level"];
          NSData *finalData = [NSJSONSerialization dataWithJSONObject:dictionary options:nil error:nil];
          NSString *finalString = [NSString stringWithUTF8String:[finalData bytes]].description;
          DDLogVerbose(@"%@", finalString);
     } else
          DDLogVerbose(@"%@", message);
}

+ (void) loadConfigurations {
     NSString *path = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
     config = [[NSDictionary alloc] initWithContentsOfFile:path];
}

+ (id) getConfigurationForKey:(NSString *)keyString {
     NSDictionary *current;
     if ([keyString containsString:@"page"]) { // page.KEY
          current = [config objectForKey:@"page"];
          keyString = [keyString substringFromIndex:(unsigned long)([keyString rangeOfString:@"."].location) + 1];
     }
     else
          current = config;
     return [current objectForKey:keyString];
}

+ (NSString *) encrypt:(NSString *)input {
     NSData * encryptedData = [[CryptLib alloc] encrypt:[input dataUsingEncoding:NSUTF8StringEncoding] key:key iv:iv];
     NSString *result = [encryptedData base64EncodedString];
     return result;
}

+ (NSString *) decrypt:(NSString *)input {
          //HERE
     NSData *encryptedData = [[CryptLib alloc] decrypt:[input base64DecodedData] key:key iv:iv];
     NSString * decrypted = [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding];
     return decrypted;
}

+ (void) setNavColorForController:(UIViewController *)controller {
     controller.navigationController.navigationBar.barTintColor = [self colorWithHexString:[self getConfigurationForKey:@"page.lightColor"]];
}

     //Convert to actual method...

     // takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
     const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
     long x = strtol(cStr+1, NULL, 16);
     return [self colorWithHex:x];
}

     // takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
     unsigned char r, g, b;
     b = col & 0xFF;
     g = (col >> 8) & 0xFF;
     r = (col >> 16) & 0xFF;
     return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end
