//
//  GroupDetailViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 2/15/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtracurricularStructure.h"

@interface GroupDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ExtracurricularStructure *EC;

@end
