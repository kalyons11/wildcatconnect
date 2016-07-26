//
//  StaffDirectoryMainTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/14/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "StaffDirectoryBaseTableViewController.h"

@interface StaffDirectoryMainTableViewController : StaffDirectoryBaseTableViewController {
     NSMutableArray *staffMembers;
     NSMutableArray *dictionaryArray;
     NSNumber *loadNumber;
}

@property (nonatomic, retain) NSMutableArray *staffMembers;
@property (nonatomic, retain) NSMutableArray *dictionaryArray;
@property (nonatomic, retain) NSNumber *loadNumber;

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber;

@end
