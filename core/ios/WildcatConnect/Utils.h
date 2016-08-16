//
//  Utils.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 8/11/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <LogglyLogger.h>
#import <LogglyFormatter.h>
#import <CocoaLumberjack/DDLog.h>

@interface Utils : NSObject

+ (void)loadConfigurations;
+ (id)getConfigurationForKey:(NSString *)keyString;
+ (NSString *)encrypt:(NSString *)input;
+ (NSString *)decrypt:(NSString *)input;
+ (void) setNavColorForController:(UIViewController *)controller;
+ (void) init;
+ (void) logString:(NSString *)message forObjects:(NSArray *)objects forLevel:(NSString *)level;

@end
