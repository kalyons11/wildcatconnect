//
//  ApplicationManager.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/15/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "ApplicationManager.h"
#import <Parse/Parse.h>
#import "StaffMemberStructure.h"

@implementation ApplicationManager

- (void)loadStaffMembers {
     PFQuery *query = [StaffMemberStructure query];
     [query orderByDescending:@"staffMemberLastName"];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          if (! error) {
               _staffMembers = (NSMutableArray *)objects;
          }
     }];
}

#pragma mark - Singleton Methods

+ (id)sharedManager {
     static ApplicationManager *sharedApplicationManager = nil;
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
          sharedApplicationManager = [[self alloc] init];
     });
     return sharedApplicationManager;
}

- (id)init {
     if (self == [super init]) {
          someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
          staffMembers = [[NSArray alloc] initWithObjects:@"TestObject", nil];
     }
     return self;
}

@end
