//
//  EventStructure.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/16/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "EventStructure.h"

@implementation EventStructure

@dynamic titleString;
@dynamic locationString;
@dynamic eventDate;
@dynamic messageString;
@dynamic isApproved;
@dynamic userString;
@dynamic ID;
@dynamic email;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"EventStructure";
}

@end
