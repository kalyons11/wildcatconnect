//
//  CommunityServiceStructure.m
//  WildcatConnectGITTest
//
//  Created by Rohith Parvathaneni on 8/17/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "CommunityServiceStructure.h"
#import <Parse/PFObject+Subclass.h>

@implementation CommunityServiceStructure

@dynamic startDate;
@dynamic endDate;
@dynamic commSummaryString;
@dynamic commTitleString;
@dynamic isApproved;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"CommunityServiceStructure";
}

@end
