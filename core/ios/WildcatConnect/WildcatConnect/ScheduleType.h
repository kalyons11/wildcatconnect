//
//  ScheduleType.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/15/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface ScheduleType : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *typeID;
@property NSString *scheduleString;
@property BOOL alertNeeded;
@property NSString *fullScheduleString;

@end
