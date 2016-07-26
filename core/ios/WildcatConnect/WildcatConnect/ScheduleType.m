//
//  ScheduleType.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/15/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "ScheduleType.h"

@implementation ScheduleType

@dynamic typeID;
@dynamic scheduleString;
@dynamic alertNeeded;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"ScheduleType";
}

@end
