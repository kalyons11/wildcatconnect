//
//  ExtracurricularsTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/17/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtracurricularsTableViewController : UITableViewController {
     NSNumber *loadNumber;
     NSMutableArray *updatesArray;
     NSMutableArray *extracurricularsArray;
     NSMutableArray *ECImagesArray;
}

@property (nonatomic, retain) NSNumber *loadNumber;
@property (nonatomic, retain) NSMutableArray *updatesArray;
@property (nonatomic, retain) NSMutableArray *extracurricularsArray;
@property (nonatomic, retain) NSMutableArray *ECImagesArray;

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber;

@end
