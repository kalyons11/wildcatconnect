//
//  EventStructure.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/16/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface EventStructure : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *titleString;
@property NSString *locationString;
@property NSDate *eventDate;
@property NSString *messageString;
@property NSNumber *isApproved;
@property NSString *userString;
@property NSString *email;
@property NSNumber *ID;

@end
