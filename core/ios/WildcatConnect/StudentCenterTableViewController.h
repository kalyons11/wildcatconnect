//
//  StudentCenterTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/3/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PollStructure.h"

@interface StudentCenterTableViewController : UITableViewController {
     NSNumber *loadNumber;
     NSMutableArray *pollArray;
     NSMutableArray *answeredPolls;
     PollStructure *selectedPollStructure;
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber;

@property (nonatomic, retain) NSNumber *loadNumber;
@property (nonatomic, retain) NSMutableArray *pollArray;
@property (nonatomic, retain) NSMutableArray *answeredPolls;
@property (nonatomic, retain) PollStructure *selectedPollStructure;

@end
