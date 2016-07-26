//
//  TestStructure.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface TestStructure : PFObject<PFSubclassing>




+ (NSString *)parseClassName;

@property (nonatomic, strong) NSString *testStructureName;
@property int isSelected; // 0 = false, 1 = true
@property int testStructureIndex;

@end
