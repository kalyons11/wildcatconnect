//
//  ErrorStructure.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/15/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface ErrorStructure : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *nameString;
@property NSString *infoString;
@property NSString *deviceToken;
@property NSString *username;
@property NSString *version;

@end
