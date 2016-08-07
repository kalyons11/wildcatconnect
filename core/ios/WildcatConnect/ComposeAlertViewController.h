//
//  ComposeAlertViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/28/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeAlertViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
     NSIndexPath *checkedIndexPath;
}

@property (nonatomic, retain) NSIndexPath *checkedIndexPath;

@end
