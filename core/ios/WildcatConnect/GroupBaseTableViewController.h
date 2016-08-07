//
//  GroupBaseTableViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/21/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExtracurricularStructure;

@interface GroupBaseTableViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate>

- (UITableViewCell *)configureCell:(UITableViewCell *)cell forGroup:(ExtracurricularStructure *)groupStructure;

@property (nonatomic, retain) NSMutableArray *groups;

@end
