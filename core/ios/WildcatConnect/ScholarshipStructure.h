//
//  ScholarshipStructure.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 3/3/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface ScholarshipStructure : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *titleString;
@property NSDate *dueDate;
@property NSString *messageString;
@property NSString *userString;
@property NSString *email;
@property NSNumber *ID;

@end
