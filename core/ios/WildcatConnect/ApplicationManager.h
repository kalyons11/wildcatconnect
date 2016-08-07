//
//  ApplicationManager.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/15/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationManager : NSObject {
    
 

    NSString *someProperty;
     NSArray *staffMembers;
}

@property (nonatomic, retain) NSString *someProperty;
@property (nonatomic, retain) NSArray *staffMembers;

+ (id)sharedManager;

- (void)loadStaffMembers;

@end
