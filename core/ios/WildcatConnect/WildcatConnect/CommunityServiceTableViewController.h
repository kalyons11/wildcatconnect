//
//  CommunityServiceTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Rohith Parvathaneni on 8/17/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommunityServiceTableViewController : UITableViewController{
    NSMutableArray *allOpps;
    NSMutableArray *updateOpps;
     NSMutableArray *oldImages;
     NSMutableArray *newImages;
    NSMutableArray *newOpps;
    NSMutableArray *oldOpps;
     NSNumber *loadNumber;
    
}
@property (nonatomic, retain) NSMutableArray *allOpps;
@property ( nonatomic, retain) NSMutableArray *updateOpps;
@property (nonatomic, retain) NSMutableArray *oldOpps;
@property (nonatomic, retain) NSMutableArray *oldImages;
@property (nonatomic, retain) NSNumber *loadNumber;

-(instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber;
@end



