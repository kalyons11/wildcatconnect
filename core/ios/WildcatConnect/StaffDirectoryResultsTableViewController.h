//
//  StaffDirectoryResultsTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/14/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "StaffDirectoryBaseTableViewController.h"
#import <MessageUI/MessageUI.h>

@interface StaffDirectoryResultsTableViewController : StaffDirectoryBaseTableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *filteredStaffMembers;

@end
