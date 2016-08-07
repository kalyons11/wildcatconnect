//
//  UsefulLinkArray.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 9/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface UsefulLinkArray : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property NSArray *linksArray;
@property NSString *headerTitle;
@property NSNumber *index;

@end
