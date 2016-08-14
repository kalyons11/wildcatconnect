//
//  Utils.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 8/11/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "Utils.h"
#import "FBEncryptorAES.h"

NSDictionary *config;
NSString *hasher = @"dc4862c8-6a8b-49b4-a0e4-fe2bda364281";

@implementation Utils

+ (void) loadConfigurations {
     NSString *path = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
     config = [[NSDictionary alloc] initWithContentsOfFile:path];
}

+ (id) getConfigurationForKey:(NSString *)keyString {
     NSDictionary *current;
     if ([keyString containsString:@"page"])
          current = [config objectForKey:@"page"];
     else
          current = config;
     return [current objectForKey:keyString];
}

+ (NSString *) encrypt:(NSString *)input {
     NSString *encrypted = [FBEncryptorAES encryptBase64String:input keyString:hasher separateLines:NO];
     return encrypted;
}

+ (NSString *) decrypt:(NSString *)input {
     NSString *decrypted = [FBEncryptorAES decryptBase64String:input keyString:hasher];
     return decrypted;
}

     //May not be needed...

+ (NSString *)encryptObject:(NSObject *)object {
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:nil error:nil];
     NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     return [self encrypt:jsonString];
}

@end
