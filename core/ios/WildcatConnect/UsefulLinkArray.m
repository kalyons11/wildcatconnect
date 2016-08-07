//
//  UsefulLinkArray.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 9/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "UsefulLinkArray.h"
#import <Parse/PFObject+Subclass.h>

@implementation UsefulLinkArray

@dynamic linksArray;
@dynamic headerTitle;
@dynamic index;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"UsefulLinkArray";
}

@end
