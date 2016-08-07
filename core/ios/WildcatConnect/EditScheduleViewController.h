//
//  EditScheduleViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/17/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableArray *scheduleArray;
@property (nonatomic, retain) NSString *modeString;

@end
