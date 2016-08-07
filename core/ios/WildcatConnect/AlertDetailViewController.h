//
//  AlertDetailViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/28/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertStructure.h"

@interface AlertDetailViewController : UIViewController

@property (nonatomic, strong) AlertStructure *alert;
@property BOOL showCloseButton;

@end
