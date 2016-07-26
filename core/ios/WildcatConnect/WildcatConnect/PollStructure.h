//
//  PollStructure.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/8/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface PollStructure : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *pollTitle;
@property NSString *pollQuestion; // 0 = Y/N, 1 = MULTIPLE CHOICE
@property NSDictionary *pollMultipleChoices; // Dictionary of strings w/ NSNumbers...
@property NSString *pollID;
@property NSString *totalResponses;
@property NSNumber *daysActive;
@property NSNumber *isActive;

@end
