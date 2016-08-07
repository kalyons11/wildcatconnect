//
//  StaffMemberStructure.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/14/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "StaffMemberStructure.h"
#import <Parse/PFObject+Subclass.h>

@implementation StaffMemberStructure

@dynamic staffMemberLastName;
@dynamic staffMemberFirstName;
@dynamic staffMemberTitle;
@dynamic staffMemberEMail;
@dynamic staffMemberLocation;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"StaffMemberStructure";
}

- (NSString *)fullNameCommaString {
     NSArray *array = [NSArray arrayWithObjects:self.staffMemberLastName, @", ", self.staffMemberFirstName, nil];
     return [array componentsJoinedByString:@""];
}

@end
