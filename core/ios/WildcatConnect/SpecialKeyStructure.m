//
//  SpecialKeyStructure.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/28/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "SpecialKeyStructure.h"
#import <Parse/PFObject+Subclass.h>

@implementation SpecialKeyStructure

@dynamic key;
@dynamic value;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"SpecialKeyStructure";
}

@end
