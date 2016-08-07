//
//  ComposeExtracurricularUpdateViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/13/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtracurricularStructure.h"

@interface ComposeExtracurricularUpdateViewController : UIViewController <UIPickerViewDelegate, UITextViewDelegate, UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *ECarray;
@property (nonatomic, strong) ExtracurricularStructure *EC;
@property (nonatomic, strong) NSMutableArray *groupArray;


@end
