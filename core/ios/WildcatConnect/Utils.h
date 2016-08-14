//
//  Utils.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 8/11/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (void)loadConfigurations;
+ (id)getConfigurationForKey:(NSString *)keyString;
+ (NSString *)encrypt:(NSString *)input;
+ (NSString *)decrypt:(NSString *)input;
+ (NSString *)encryptObject:(NSObject *)object;

@end
