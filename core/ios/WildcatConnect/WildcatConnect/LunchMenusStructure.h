//
//  LunchMenusStructure.h
//  WildcatConnectGITTest
//
//  Created by Rohith Parvathaneni on 8/19/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface LunchMenusStructure : PFObject<PFSubclassing>

@property NSString *breakfastString;
@property NSString *lunchString;
@property NSString *dateString;
@property NSNumber *lunchStructureID;

@end
