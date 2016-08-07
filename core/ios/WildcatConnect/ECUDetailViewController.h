//
//  ECUDetailViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 2/18/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtracurricularUpdateStructure.h"

@interface ECUDetailViewController : UIViewController

@property (nonatomic, strong) ExtracurricularUpdateStructure *ECU;

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *messageString;
@property (nonatomic, strong) NSString *dateString;

@end
