//
//  SchoolDayStructure.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/14/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "SchoolDayStructure.h"
#import <Parse/PFObject+Subclass.h>

@implementation SchoolDayStructure

@dynamic schoolDayID;
@dynamic schoolDate;
@dynamic scheduleType;
@dynamic messageString;
@dynamic hasImage;
@dynamic imageFile;
@dynamic imageString;
@dynamic imageUser;
@dynamic customSchedule;
@dynamic imageUserFullString;
@dynamic customString;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"SchoolDayStructure";
}

@end
