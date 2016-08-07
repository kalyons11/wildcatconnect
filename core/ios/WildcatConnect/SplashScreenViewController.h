//
//  SplashScreenViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashScreenViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *StartImage;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end
