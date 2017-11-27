//
//  ExtracurricularUpdateStructure.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/17/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "ExtracurricularUpdateStructure.h"
#import <Parse/PFObject+Subclass.h>

@implementation ExtracurricularUpdateStructure

@dynamic extracurricularID;
@dynamic messageString;
@dynamic extracurricularUpdateID;
@dynamic postDate;

+ (void)load {
     [self registerSubclass];
}

+ (NSString *)parseClassName {
     return @"ExtracurricularUpdateStructure";
}

- (ExtracurricularStructure *)getStructureForUpdate:(ExtracurricularUpdateStructure *)update withArray:(NSMutableArray *)array {
     NSNumber *ID = update.extracurricularID;
     for (ExtracurricularStructure *e in array) {
          if (e.extracurricularID == ID) {
               return e;
          }
     }
     return nil;
}

@end
