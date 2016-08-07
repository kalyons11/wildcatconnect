//
//  PollDetailViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/8/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PollStructure.h"

@interface PollDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
     NSIndexPath *checkedIndexPath;
     NSMutableArray *choicesArray;
     NSMutableArray *valuesArray;
     BOOL hasAnswered;
}

@property (nonatomic, retain) PollStructure *pollStructure;
@property (nonatomic, strong) NSIndexPath *checkedIndexPath;
@property (nonatomic, strong) NSMutableArray *choicesArray;
@property (nonatomic, strong) NSMutableArray *valuesArray;
@property (nonatomic) BOOL hasAnswered;

@end
