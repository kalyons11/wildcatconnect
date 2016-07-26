//
//  ErrorStructure.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/15/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "ErrorStructure.h"

@implementation ErrorStructure

@dynamic nameString;
@dynamic infoString;
@dynamic deviceToken;
@dynamic username;
@dynamic version;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"ErrorStructure";
}

@end
