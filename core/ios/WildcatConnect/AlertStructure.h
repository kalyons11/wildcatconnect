//
//  AlertStructure.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/8/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface AlertStructure : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property NSString *titleString;
@property NSString *authorString;
@property NSString *contentString; //could change depending on future web structure...
@property NSNumber *alertID;
@property NSDate *alertTime;
@property NSNumber *hasTime;
@property NSString *dateString;
@property NSNumber *isReady;
@property NSNumber *views;

@end
