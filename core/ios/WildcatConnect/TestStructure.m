//
//  TestStructure.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "TestStructure.h"
#import <Parse/PFObject+Subclass.h>

@implementation TestStructure

@dynamic testStructureName;
@dynamic isSelected;
@dynamic testStructureIndex;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"TestStructure";
}

- (NSUInteger)lengthOfName {
     return [self.testStructureName length];
}

@end
