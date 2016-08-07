//
//  SpecialKeyStructure.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/28/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface SpecialKeyStructure : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *key;
@property NSString *value;

@end
