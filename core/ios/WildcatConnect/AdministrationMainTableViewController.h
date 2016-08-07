//
//  AdministrationMainTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/4/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdministrationMainTableViewController : UITableViewController <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UINavigationBar *topBar;
@property (nonatomic, strong) NSMutableArray *sectionsArray;
@property (nonatomic, strong) NSMutableArray *sectionsImagesArray;

@end
