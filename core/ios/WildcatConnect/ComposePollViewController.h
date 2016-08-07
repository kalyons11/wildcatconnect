//
//  ComposePollViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/12/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposePollViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *choicesArray;

@end
