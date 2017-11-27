//
//  PushSettingsTableViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/12/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PushSettingsTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *ECarray;
@property (nonatomic, strong) NSMutableArray *pushArray;

@end
