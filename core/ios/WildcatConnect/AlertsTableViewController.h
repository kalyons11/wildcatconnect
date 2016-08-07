//
//  AlertsTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/8/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertStructure.h"

@interface AlertsTableViewController : UITableViewController {
     NSMutableArray *alerts;
     NSNumber *loadNumber;
     NSMutableArray *readAlerts;
     AlertStructure *selectedAlertStructure;
}

@property (nonatomic, retain) NSMutableArray *alerts;
@property (nonatomic, retain) NSNumber *loadNumber;
@property (nonatomic, retain) NSMutableArray *readAlerts;
@property (nonatomic, retain) AlertStructure *selectedAlertStructure;

- (void)replaceAlertStructure:(AlertStructure *)alertStructure;

@end
