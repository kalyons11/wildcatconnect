//
//  LunchMenusViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/12/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LunchMenusViewController : UITableViewController{
    
     NSMutableArray *theStructuresArray;
    
}
@property (nonatomic, strong) NSMutableArray *theStructuresArray;

@property CGFloat cellHeight;

@end
