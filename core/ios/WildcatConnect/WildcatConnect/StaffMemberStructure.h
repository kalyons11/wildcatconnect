//
//  StaffMemberStructure.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/14/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface StaffMemberStructure : PFObject<PFSubclassing>


+ (NSString *)parseClassName;

@property NSString *staffMemberLastName;
@property NSString *staffMemberFirstName;
@property NSString *staffMemberTitle;
@property NSString *staffMemberEMail;
@property NSString *staffMemberLocation;

- (NSString *)fullNameCommaString;

@end
