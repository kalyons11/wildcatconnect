//
//  UserRegisterStructure.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/26/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserRegisterStructure : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *firstName;
@property NSString *lastName;
@property NSString *email;
@property NSString *username;
@property NSString *password;
@property NSString *key;

@end
