//
//  EventsTableViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/16/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsTableViewController : UITableViewController {
     NSNumber *loadNumber;
     NSMutableArray *todayEvents;
     NSMutableArray *upcomingEvents;
     NSMutableArray *allEvents;
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber;

@property (nonatomic, retain) NSNumber *loadNumber;
@property (nonatomic, retain) NSMutableArray *todayEvents;
@property (nonatomic, retain) NSMutableArray *upcomingEvents;
@property (nonatomic, retain) NSMutableArray *allEvents;

@end
