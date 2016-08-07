//
//  EditPictureDayViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/22/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPictureDayViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSString *dayString;

@end
