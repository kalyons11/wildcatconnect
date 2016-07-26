//
//  CustomScheduleViewController.h
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/21/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomScheduleViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *scheduleString;
@property (nonatomic, retain) NSNumber *IDString;

@end
