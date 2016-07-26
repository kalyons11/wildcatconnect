//
//  ScholarshipTableViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 3/7/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScholarshipTableViewController : UITableViewController {
     NSMutableArray *scholarships;
     NSNumber *loadNumber;
}

@property (nonatomic, retain) NSMutableArray *scholarships;
@property (nonatomic, retain) NSNumber *loadNumber;

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber;

@end
