//
//  ScholarshipStructure.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 3/3/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "ScholarshipStructure.h"

@implementation ScholarshipStructure

@dynamic titleString;
@dynamic dueDate;
@dynamic messageString;
@dynamic userString;
@dynamic email;
@dynamic ID;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"ScholarshipStructure";
}

@end
