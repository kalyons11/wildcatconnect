//
//  UserRegisterStructure.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/26/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "UserRegisterStructure.h"
#import <Parse/PFObject+Subclass.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation UserRegisterStructure

@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic username;
@dynamic password;
@dynamic key;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"UserRegisterStructure";
}

@end
