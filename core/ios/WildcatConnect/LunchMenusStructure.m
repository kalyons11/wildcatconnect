//
//  LunchMenusStructure.m
//  WildcatConnectGITTest
//
//  Created by Rohith Parvathaneni on 8/19/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "LunchMenusStructure.h"

@implementation LunchMenusStructure

@dynamic breakfastString;
@dynamic lunchString;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"LunchMenusStructure";
}

@end
