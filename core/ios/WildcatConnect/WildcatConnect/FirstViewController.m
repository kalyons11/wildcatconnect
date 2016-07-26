//
//  FirstViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/12/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "FirstViewController.h"
#import <Parse/Parse.h>
#import "NewsArticleStructure.h"
#import "ExtracurricularUpdateStructure.h"
#import "PollStructure.h"
#import "AppManager.h"
#import "SchoolDayStructure.h"
#import "ScheduleType.h"
#import "AlertStructure.h"
#import "LunchMenusStructure.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "EventStructure.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SpecialKeyStructure.h"
#import "EventsTableViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController {
     UIScrollView *scrollView;
     UILabel *titleLabelA;
     UILabel *titleLabelB;
     UILabel *titleLabelC;
     SchoolDayStructure *schoolDay;
     ScheduleType *scheduleType;
     UILabel *dayLabel;
     UIActivityIndicatorView *activity;
     UILabel *scheduleLabel;
     UILabel *messageLabelA;
     UITextView *messageLabelB;
     UILabel *messageLabelC;
     UITextView *messageLabelD;
     UILabel *lunchLabelA;
     UITextView *lunchLabelB;
     NSData *imageData;
     UILabel *imageLabel;
     UITextView *imageLabelB;
     NSNumber *hasImage;
     NSString *breakfastString;
     NSString *lunchString;
     BOOL connected;
     UIImageView *theImageView;
     BOOL failed;
     BOOL isSummer;
     UIView *theSep;
     NSInteger theInt;
     UIAlertView *av;
     UILabel *titleLabel;
}

- (void)backDoor {
     theInt = theInt + 1;
     if (theInt == 11) {
          av = [[UIAlertView alloc] initWithTitle:@"Developer Access" message:@"Developer Password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
          av.alertViewStyle = UIAlertViewStylePlainTextInput;
          [av textFieldAtIndex:0].secureTextEntry = YES;
          [av show];
     }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (actionSheet == av) {
          if (buttonIndex == 1) {
               NSString *choiceText = [actionSheet textFieldAtIndex:0].text;
               [self getPasswordStringMethodWithCompletion:^(NSError *error, NSString *passwordString) {
                    if ([choiceText isEqualToString:passwordString]) {
                         [titleLabel removeFromSuperview];
                         [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         [self viewWillAppear:YES];
                    } else {
                         theInt = 0;
                    }
               }];
          }
     }
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     
     self.navigationController.navigationItem.title = @"Home";
     
     UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logoSmall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:nil action:nil];
     bar.enabled = false;
     self.navigationItem.leftBarButtonItem = bar;
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     Reachability *reachability = [Reachability reachabilityForInternetConnection];
     NetworkStatus networkStatus = [reachability currentReachabilityStatus];
     connected = (networkStatus != NotReachable);
     
     NSString *loadString = [[NSUserDefaults standardUserDefaults] objectForKey:@"reloadHomePage"];
     if ((! loadString || [loadString isEqual:@"1"] == true) && connected == true) {
          if (scrollView) {
               [scrollView removeFromSuperview];
          }
          scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
          self.navigationController.navigationBar.translucent = NO;
          
          [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"reloadHomePage"];
          [[NSUserDefaults standardUserDefaults] synchronize];
               
          activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          [barButtonItem release];
          
          [self getStatusStringMethodWithCompletion:^(NSError *error, NSString *statusString, NSString *messageString) {
               if ([statusString isEqualToString:@"0"] && theInt == 0) {
                    [activity stopAnimating];
                    [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:FALSE];
                    [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:FALSE];
                    [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:FALSE];
                    [[[[self.tabBarController tabBar]items]objectAtIndex:3]setEnabled:FALSE];
                    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
                    titleLabel.text = [@"WildcatConnect is currently disabled.\n\nMESSAGE - " stringByAppendingString:messageString];
                    [titleLabel setFont:[UIFont systemFontOfSize:24]];
                    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    titleLabel.numberOfLines = 0;
                    [titleLabel sizeToFit];
                    [self.view addSubview:titleLabel];
                    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logoSmall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backDoor)];
                    bar.enabled = true;
                    self.navigationItem.leftBarButtonItem = bar;
               } else {
                    
                    [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:true];
                    [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:true];
                    [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:true];
                    [[[[self.tabBarController tabBar]items]objectAtIndex:3]setEnabled:true];
                    schoolDay = [[SchoolDayStructure alloc] init];
                    scheduleType = [[ScheduleType alloc] init];
                    imageData = [NSData data];
                    
                    breakfastString = [[NSString alloc] init];
                    lunchString = [[NSString alloc] init];
                    
                    self.vacationString = [[NSString alloc] init];
                    
                    isSummer = false;
                    
                    [self getModeStringMethodWithCompletion:^(NSError *error, NSString *modeString) {
                         self.vacationString = modeString;
                         if ([self.vacationString isEqualToString:@"NORMAL"]) {
                              self.vacationString = @"";
                         } else if ([self.vacationString isEqualToString:@"SUMMER"]) {
                              isSummer = true;
                         } else {
                              self.vacationString = [self.vacationString stringByAppendingString:@" - "];
                         }
                         
                         titleLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
                         NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                         [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                         [dateFormatter setDateFormat:@"EEEE"];
                         NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
                         titleLabelB.text = [currentDate stringByAppendingString:@","];
                         [titleLabelB setFont:[UIFont systemFontOfSize:32]];
                         titleLabelB.lineBreakMode = NSLineBreakByWordWrapping;
                         titleLabelB.numberOfLines = 0;
                         [titleLabelB sizeToFit];
                         [scrollView addSubview:titleLabelB];
                         
                         titleLabelC = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLabelB.frame.origin.y + titleLabelB.frame.size.height, 0, 0)];
                         [dateFormatter setDateFormat:@", yyyy"];
                         currentDate = [dateFormatter stringFromDate:[NSDate date]];
                         
                         NSDate *date = [NSDate date];
                         NSDateFormatter *prefixDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                         [prefixDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
                         [prefixDateFormatter setDateFormat:@"MMMM d"];
                         NSString *prefixDateString = [prefixDateFormatter stringFromDate:date];
                         
                         NSDateFormatter *monthDayFormatter = [[[NSDateFormatter alloc] init] autorelease];
                         [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
                         [monthDayFormatter setDateFormat:@"d"];
                         int date_day = [[monthDayFormatter stringFromDate:[NSDate date]] intValue];
                         NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
                         NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
                         NSString *suffix = [suffixes objectAtIndex:date_day];
                         NSString *dateString = [[prefixDateString stringByAppendingString:suffix] stringByAppendingString:currentDate];
                         
                         titleLabelC.text = dateString;
                         [titleLabelC setFont:[UIFont systemFontOfSize:32]];
                         titleLabelC.lineBreakMode = NSLineBreakByWordWrapping;
                         titleLabelC.numberOfLines = 0;
                         [titleLabelC sizeToFit];
                         [scrollView addSubview:titleLabelC];
                         
                         theSep = [[UIView alloc] initWithFrame:CGRectMake(10, titleLabelC.frame.origin.y + titleLabelC.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                         theSep.backgroundColor = [UIColor blackColor];
                         [scrollView addSubview:theSep];
                         
                         if (isSummer == true) {
                              dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, theSep.frame.origin.y + theSep.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                              dayLabel.text = @"ENJOY SUMMER";
                              dayLabel.textColor = [UIColor redColor];
                              [dayLabel setFont:[UIFont systemFontOfSize:22]];
                              dayLabel.lineBreakMode = NSLineBreakByWordWrapping;
                              dayLabel.numberOfLines = 0;
                              [dayLabel sizeToFit];
                              [dayLabel setTextAlignment:UITextAlignmentCenter];
                              dayLabel.frame = CGRectMake(self.view.frame.size.width / 2 - dayLabel.frame.size.width / 2, dayLabel.frame.origin.y, dayLabel.frame.size.width, dayLabel.frame.size.height);
                              [scrollView addSubview:dayLabel];
                              
                              self.automaticallyAdjustsScrollViewInsets = NO;
                              UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 120, 0);
                              scrollView.contentInset = adjustForTabbarInsets;
                              scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                              CGRect contentRect = CGRectZero;
                              for (UIView *view in scrollView.subviews) {
                                   contentRect = CGRectUnion(contentRect, view.frame);
                              }
                              scrollView.contentSize = contentRect.size;
                              
                              [self.view addSubview:scrollView];
                              
                              [activity stopAnimating];
                              
                         } else {
                              [self getCurrentSchoolDayMethodWithCompletion:^(NSError *error, NSMutableArray *theDay) {
                                   if (error != nil) {
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Tap refresh button to try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                        [alertView show];
                                        dispatch_async(dispatch_get_main_queue(), ^ {
                                             [activity stopAnimating];
                                             [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                             UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewWillAppear:)];
                                             self.navigationItem.rightBarButtonItem = barButtonItem;
                                             [activity startAnimating];
                                             [barButtonItem release];
                                             [self showBadImage];
                                        });
                                   } else {
                                             //If after 7 PM ON the school day, then need to change...
                                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                                        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
                                        NSString *potentialString = [[theDay objectAtIndex:0] objectForKey:@"schoolDate"];
                                        NSInteger index = 0;
                                        if ([dateString isEqualToString:potentialString]) {
                                             [dateFormatter setDateFormat:@"H"];
                                             dateString = [dateFormatter stringFromDate:[NSDate date]];
                                             NSInteger hour = [dateString integerValue];
                                             if (hour >= 17) {
                                                  index = 1;
                                             }
                                        }
                                        schoolDay.schoolDate = [[theDay objectAtIndex:index] objectForKey:@"schoolDate"];
                                        hasImage = [[theDay objectAtIndex:index] objectForKey:@"hasImage"];
                                        schoolDay.imageFile = [[theDay objectAtIndex:index] objectForKey:@"imageFile"];
                                        schoolDay.imageString = [[theDay objectAtIndex:index] objectForKey:@"imageString"];
                                        schoolDay.messageString = [[theDay objectAtIndex:index] objectForKey:@"messageString"];
                                        schoolDay.scheduleType = [[theDay objectAtIndex:index] objectForKey:@"scheduleType"];
                                        schoolDay.schoolDayID = [[theDay objectAtIndex:index] objectForKey:@"schoolDayID"];
                                        schoolDay.customSchedule = [[theDay objectAtIndex:index] objectForKey:@"customSchedule"];
                                        schoolDay.customString = [[theDay objectAtIndex:index] objectForKey:@"customString"];
                                        schoolDay.breakfastString = [[theDay objectAtIndex:index] objectForKey:@"breakfastString"];
                                        schoolDay.lunchString = [[theDay objectAtIndex:index] objectForKey:@"lunchString"];
                                        
                                        if ([schoolDay.scheduleType isEqual:@"*"]) {
                                             
                                             dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, theSep.frame.origin.y + theSep.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                             NSDateFormatter* day = [[NSDateFormatter alloc] init];
                                             [day setDateFormat: @"EEEE"];
                                             NSString *today = [day stringFromDate:[NSDate date]];
                                             NSDateFormatter *prefixDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                                             NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                                             dateFormatter = [[NSDateFormatter alloc] init];
                                                  // this is imporant - we set our input date format to match our input string
                                                  // if format doesn't match you'll get nil from your string, so be careful
                                             [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                                             NSDate *dateFromString = [[NSDate alloc] init];
                                                  // voila!
                                             dateFromString = [dateFormatter dateFromString:schoolDay.schoolDate];
                                             NSString *actual = [day stringFromDate:dateFromString];
                                             if ([today isEqualToString:actual]) {
                                                  dayLabel.text = schoolDay.customString;
                                             } else {
                                                  dayLabel.text = [self.vacationString stringByAppendingString:[[actual stringByAppendingString:@" - "] stringByAppendingString:schoolDay.customString]];
                                             }
                                             dayLabel.textColor = [UIColor redColor];
                                             [dayLabel setFont:[UIFont systemFontOfSize:22]];
                                             dayLabel.lineBreakMode = NSLineBreakByWordWrapping;
                                             dayLabel.numberOfLines = 0;
                                             [dayLabel sizeToFit];
                                             [dayLabel setTextAlignment:UITextAlignmentCenter];
                                             dayLabel.frame = CGRectMake(self.view.frame.size.width / 2 - dayLabel.frame.size.width / 2, dayLabel.frame.origin.y, dayLabel.frame.size.width, dayLabel.frame.size.height);
                                             [scrollView addSubview:dayLabel];
                                             
                                             scheduleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, dayLabel.frame.origin.y + dayLabel.frame.size.height + 10, self.view.frame.size.width - 20, 120)];
                                             scheduleLabel.text = schoolDay.customSchedule;
                                             [scheduleLabel setFont:[UIFont systemFontOfSize:14]];
                                             scheduleLabel.numberOfLines = 0;
                                             [scheduleLabel sizeToFit];
                                             [scheduleLabel setTextAlignment:UITextAlignmentCenter];
                                             scheduleLabel.frame = CGRectMake(self.view.frame.size.width / 2 - scheduleLabel.frame.size.width / 2, scheduleLabel.frame.origin.y, scheduleLabel.frame.size.width, scheduleLabel.frame.size.height);
                                             [scrollView addSubview:scheduleLabel];
                                             
                                             [self getAlertStringMethodWithCompletion:^(NSError *error, NSString *eventString) {
                                                  
                                                  UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, scheduleLabel.frame.origin.y + scheduleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                  separator.backgroundColor = [UIColor blackColor];
                                                  [scrollView addSubview:separator];
                                                  
                                                  messageLabelA = [[UILabel alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                  UIFont *font = [UIFont systemFontOfSize:14];
                                                  [messageLabelA setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                  if (! [eventString isEqualToString:@"No recent alerts."]) {
                                                       messageLabelA.text = @"Recent Alerts (VIEW ALL)";
                                                  } else {
                                                       messageLabelA.text = @"Recent Alerts";
                                                  }
                                                  messageLabelA.lineBreakMode = NSLineBreakByWordWrapping;
                                                  messageLabelA.numberOfLines = 0;
                                                  [messageLabelA sizeToFit];
                                                  messageLabelA.frame = CGRectMake(self.view.frame.size.width / 2 - messageLabelA.frame.size.width / 2, messageLabelA.frame.origin.y, messageLabelA.frame.size.width, messageLabelA.frame.size.height);
                                                  [scrollView addSubview:messageLabelA];
                                                  
                                                  if (! [eventString isEqualToString:@"No recent alerts."]) {
                                                       NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Recent Alerts (VIEW ALL)" attributes:nil];
                                                       NSRange linkRange = NSMakeRange(14, 10); // for the word "link" in the string above
                                                       
                                                       NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                                                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
                                                       [attributedString setAttributes:linkAttributes range:linkRange];
                                                       
                                                            // Assign attributedText to UILabel
                                                       messageLabelA.attributedText = attributedString;
                                                       UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertOpen)];
                                                            // if labelView is not set userInteractionEnabled, you must do so
                                                       [messageLabelA setUserInteractionEnabled:YES];
                                                       [messageLabelA addGestureRecognizer:gesture];
                                                  }
                                                  
                                                  messageLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, messageLabelA.frame.origin.y + messageLabelA.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                  messageLabelB.text = [eventString copy];
                                                  messageLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                  messageLabelB.editable = false;
                                                  messageLabelB.scrollEnabled = false;
                                                  [messageLabelB setFont:[UIFont systemFontOfSize:16]];
                                                  [messageLabelB sizeToFit];
                                                  [scrollView addSubview:messageLabelB];
                                                  
                                                  UIView *separatorX = [[UIView alloc] initWithFrame:CGRectMake(10, messageLabelB.frame.origin.y + messageLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                  separatorX.backgroundColor = [UIColor blackColor];
                                                  [scrollView addSubview:separatorX];
                                                  
                                                  [self getEventStringMethodWithCompletion:^(NSError *error, NSString *eventString) {
                                                       if (error != nil) {
                                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Tap refresh button to try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                            [alertView show];
                                                            dispatch_async(dispatch_get_main_queue(), ^ {
                                                                 [activity stopAnimating];
                                                                 [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                                 UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewWillAppear:)];
                                                                 self.navigationItem.rightBarButtonItem = barButtonItem;
                                                                 [activity startAnimating];
                                                                 [barButtonItem release];
                                                                 [self showBadImage];
                                                            });
                                                       } else {
                                                            messageLabelC = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorX.frame.origin.y + separatorX.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                            UIFont *font = [UIFont systemFontOfSize:14];
                                                            [messageLabelC setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                            if (! [eventString isEqualToString:@"No upcoming events."]) {
                                                                 messageLabelC.text = @"Upcoming Events (VIEW ALL)";
                                                            } else {
                                                                 messageLabelC.text = @"Upcoming Events";
                                                            }
                                                            messageLabelC.lineBreakMode = NSLineBreakByWordWrapping;
                                                            messageLabelC.numberOfLines = 0;
                                                            [messageLabelC sizeToFit];
                                                            messageLabelC.frame = CGRectMake(self.view.frame.size.width / 2 - messageLabelC.frame.size.width / 2, messageLabelC.frame.origin.y, messageLabelC.frame.size.width, messageLabelC.frame.size.height);
                                                            [scrollView addSubview:messageLabelC];
                                                            
                                                            if (! [eventString isEqualToString:@"No upcoming events."]) {
                                                                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Upcoming Events (VIEW ALL)" attributes:nil];
                                                                 NSRange linkRange = NSMakeRange(16, 10); // for the word "link" in the string above
                                                                 
                                                                 NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                                                                                   NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
                                                                 [attributedString setAttributes:linkAttributes range:linkRange];
                                                                 
                                                                      // Assign attributedText to UILabel
                                                                 messageLabelC.attributedText = attributedString;
                                                                 UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventsOpen)];
                                                                      // if labelView is not set userInteractionEnabled, you must do so
                                                                 [messageLabelC setUserInteractionEnabled:YES];
                                                                 [messageLabelC addGestureRecognizer:gesture];
                                                            }
                                                            
                                                            messageLabelD = [[UITextView alloc] initWithFrame:CGRectMake(10, messageLabelC.frame.origin.y + messageLabelC.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                            messageLabelD.text = [eventString copy];
                                                            messageLabelD.dataDetectorTypes = UIDataDetectorTypeLink;
                                                            messageLabelD.editable = false;
                                                            messageLabelD.scrollEnabled = false;
                                                            [messageLabelD setFont:[UIFont systemFontOfSize:16]];
                                                            [messageLabelD sizeToFit];
                                                            [scrollView addSubview:messageLabelD];
                                                            
                                                            if ([hasImage integerValue] == 1) {
                                                                      //ADD IMAGE!!!
                                                                 [self getImageDataMethodWithCompletion:^(NSError *error, NSMutableArray *returnData) {
                                                                      
                                                                      imageData = [returnData objectAtIndex:0];
                                                                      UIImage *image = [[UIImage alloc] init];
                                                                      
                                                                      image = [UIImage imageWithData:imageData];
                                                                      
                                                                      UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, messageLabelD.frame.origin.y + messageLabelD.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                                      separator.backgroundColor = [UIColor blackColor];
                                                                      [scrollView addSubview:separator];
                                                                      
                                                                      imageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                      UIFont *font = [UIFont systemFontOfSize:14];
                                                                      [imageLabel setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                                      imageLabel.text = @"Picture of the Day";
                                                                      imageLabel.lineBreakMode = NSLineBreakByWordWrapping;
                                                                      imageLabel.numberOfLines = 0;
                                                                      [imageLabel sizeToFit];
                                                                      imageLabel.frame = CGRectMake(self.view.frame.size.width / 2 - imageLabel.frame.size.width / 2, imageLabel.frame.origin.y, imageLabel.frame.size.width, imageLabel.frame.size.height);
                                                                      [scrollView addSubview:imageLabel];
                                                                      
                                                                      UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 300)];
                                                                      
                                                                      if (image.size.width > self.view.frame.size.width - 20) {
                                                                           image = [[AppManager getInstance] imageFromImage:image scaledToWidth:self.view.frame.size.width - 20];
                                                                      }
                                                                      imageView.image = image;
                                                                      [imageView sizeToFit];
                                                                      imageView.frame = CGRectMake(self.view.frame.size.width / 2 - imageView.frame.size.width / 2, imageLabel.frame.origin.y + imageLabel.frame.size.height + 10, imageView.frame.size.width, imageView.frame.size.height);
                                                                      [scrollView addSubview:imageView];
                                                                      
                                                                      imageLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                      [imageLabelB setFont:[UIFont systemFontOfSize:16]];
                                                                      imageLabelB.text = schoolDay.imageString;
                                                                      imageLabelB.editable = false;
                                                                      imageLabelB.scrollEnabled = false;
                                                                      imageLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                                      [imageLabelB sizeToFit];
                                                                      [scrollView addSubview:imageLabelB];
                                                                      
                                                                      UIView *separatorY = [[UIView alloc] initWithFrame:CGRectMake(10, imageLabelB.frame.origin.y + imageLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                                      separatorY.backgroundColor = [UIColor blackColor];
                                                                      [scrollView addSubview:separatorY];
                                                                      
                                                                      lunchLabelA = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorY.frame.origin.y + separatorY.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                      [lunchLabelA setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                                      lunchLabelA.text = @"Food";
                                                                      lunchLabelA.lineBreakMode = NSLineBreakByWordWrapping;
                                                                      lunchLabelA.numberOfLines = 0;
                                                                      [lunchLabelA sizeToFit];
                                                                      lunchLabelA.frame = CGRectMake(self.view.frame.size.width / 2 - lunchLabelA.frame.size.width / 2, lunchLabelA.frame.origin.y, lunchLabelA.frame.size.width, lunchLabelA.frame.size.height);
                                                                      [scrollView addSubview:lunchLabelA];
                                                                      
                                                                      lunchLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, lunchLabelA.frame.origin.y + lunchLabelA.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                      NSString *lunch = @"Lunch: ";
                                                                      lunchLabelB.text = [@"Breakfast: " stringByAppendingString:[[[schoolDay.breakfastString stringByAppendingString:@"\n\n"] stringByAppendingString:lunch] stringByAppendingString:schoolDay.lunchString]];
                                                                      lunchLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                                      lunchLabelB.editable = false;
                                                                      lunchLabelB.scrollEnabled = false;
                                                                      [lunchLabelB setFont:[UIFont systemFontOfSize:16]];
                                                                      [lunchLabelB sizeToFit];
                                                                      [scrollView addSubview:lunchLabelB];
                                                                      
                                                                      self.automaticallyAdjustsScrollViewInsets = NO;
                                                                      UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 120, 0);
                                                                      scrollView.contentInset = adjustForTabbarInsets;
                                                                      scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                                                                      CGRect contentRect = CGRectZero;
                                                                      for (UIView *view in scrollView.subviews) {
                                                                           contentRect = CGRectUnion(contentRect, view.frame);
                                                                      }
                                                                      scrollView.contentSize = contentRect.size;
                                                                      
                                                                      [self.view addSubview:scrollView];
                                                                      
                                                                      [activity stopAnimating];
                                                                 }];
                                                            }
                                                            else {
                                                                 
                                                                 UIView *separatorY = [[UIView alloc] initWithFrame:CGRectMake(10, messageLabelD.frame.origin.y + messageLabelD.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                                 separatorY.backgroundColor = [UIColor blackColor];
                                                                 [scrollView addSubview:separatorY];
                                                                 
                                                                 lunchLabelA = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorY.frame.origin.y + separatorY.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                 [lunchLabelA setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                                 lunchLabelA.text = @"Food";
                                                                 lunchLabelA.lineBreakMode = NSLineBreakByWordWrapping;
                                                                 lunchLabelA.numberOfLines = 0;
                                                                 [lunchLabelA sizeToFit];
                                                                 lunchLabelA.frame = CGRectMake(self.view.frame.size.width / 2 - lunchLabelA.frame.size.width / 2, lunchLabelA.frame.origin.y, lunchLabelA.frame.size.width, lunchLabelA.frame.size.height);
                                                                 [scrollView addSubview:lunchLabelA];
                                                                 
                                                                 lunchLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, lunchLabelA.frame.origin.y + lunchLabelA.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                 NSString *lunch = @"Lunch: ";
                                                                 lunchLabelB.text = [@"Breakfast: " stringByAppendingString:[[[schoolDay.breakfastString stringByAppendingString:@"\n\n"] stringByAppendingString:lunch] stringByAppendingString:schoolDay.lunchString]];
                                                                 lunchLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                                 lunchLabelB.editable = false;
                                                                 lunchLabelB.scrollEnabled = false;
                                                                 [lunchLabelB setFont:[UIFont systemFontOfSize:16]];
                                                                 [lunchLabelB sizeToFit];
                                                                 [scrollView addSubview:lunchLabelB];
                                                                 
                                                                 self.automaticallyAdjustsScrollViewInsets = NO;
                                                                 UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 120, 0);
                                                                 scrollView.contentInset = adjustForTabbarInsets;
                                                                 scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                                                                 CGRect contentRect = CGRectZero;
                                                                 for (UIView *view in scrollView.subviews) {
                                                                      contentRect = CGRectUnion(contentRect, view.frame);
                                                                 }
                                                                 scrollView.contentSize = contentRect.size;
                                                                 
                                                                 [self.view addSubview:scrollView];
                                                                 
                                                                 [activity stopAnimating];
                                                            }
                                                       }
                                                  }];
                                             }];
                                        } else {
                                             [self getScheduleStringMethodWithCompletion:^(NSError *error, NSMutableArray *returnSchedule) {
                                                       //
                                                  if (error != nil) {
                                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Tap refresh button to try again.Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                       [alertView show];
                                                       dispatch_async(dispatch_get_main_queue(), ^ {
                                                            [activity stopAnimating];
                                                            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                                            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewWillAppear:)];
                                                            self.navigationItem.rightBarButtonItem = barButtonItem;
                                                            [barButtonItem release];
                                                            [self showBadImage];
                                                       });
                                                  } else {
                                                       scheduleType = [returnSchedule objectAtIndex:0];
                                                       scheduleType.scheduleString = [[returnSchedule objectAtIndex:0] objectForKey:@"scheduleString"];
                                                       scheduleType.fullScheduleString = [[returnSchedule objectAtIndex:0] objectForKey:@"fullScheduleString"];
                                                       
                                                       titleLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 0, 0)];
                                                       NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                                                       [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
                                                       [dateFormatter setDateFormat:@"EEEE"];
                                                       NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
                                                       titleLabelB.text = [currentDate stringByAppendingString:@","];
                                                       [titleLabelB setFont:[UIFont systemFontOfSize:32]];
                                                       titleLabelB.lineBreakMode = NSLineBreakByWordWrapping;
                                                       titleLabelB.numberOfLines = 0;
                                                       [titleLabelB sizeToFit];
                                                       [scrollView addSubview:titleLabelB];
                                                       
                                                       titleLabelC = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLabelB.frame.origin.y + titleLabelB.frame.size.height, 0, 0)];
                                                       [dateFormatter setDateFormat:@", yyyy"];
                                                       currentDate = [dateFormatter stringFromDate:[NSDate date]];
                                                       
                                                       NSDate *date = [NSDate date];
                                                       NSDateFormatter *prefixDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                                                       [prefixDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
                                                       [prefixDateFormatter setDateFormat:@"MMMM d"];
                                                       NSString *prefixDateString = [prefixDateFormatter stringFromDate:date];
                                                       
                                                       NSDateFormatter *monthDayFormatter = [[[NSDateFormatter alloc] init] autorelease];
                                                       [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
                                                       [monthDayFormatter setDateFormat:@"d"];
                                                       int date_day = [[monthDayFormatter stringFromDate:[NSDate date]] intValue];
                                                       NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
                                                       NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
                                                       NSString *suffix = [suffixes objectAtIndex:date_day];
                                                       NSString *dateString = [[prefixDateString stringByAppendingString:suffix] stringByAppendingString:currentDate];
                                                       
                                                       titleLabelC.text = dateString;
                                                       [titleLabelC setFont:[UIFont systemFontOfSize:32]];
                                                       titleLabelC.lineBreakMode = NSLineBreakByWordWrapping;
                                                       titleLabelC.numberOfLines = 0;
                                                       [titleLabelC sizeToFit];
                                                       [scrollView addSubview:titleLabelC];
                                                       
                                                       UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, titleLabelC.frame.origin.y + titleLabelC.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                       separator.backgroundColor = [UIColor blackColor];
                                                       [scrollView addSubview:separator];
                                                       
                                                       dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                       NSDateFormatter* day = [[NSDateFormatter alloc] init];
                                                       [day setDateFormat: @"EEEE"];
                                                       dateFormatter = [[NSDateFormatter alloc] init];
                                                            // this is imporant - we set our input date format to match our input string
                                                            // if format doesn't match you'll get nil from your string, so be careful
                                                       [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                                                       NSDate *dateFromString = [[NSDate alloc] init];
                                                            // voila!
                                                       dateFromString = [dateFormatter dateFromString:schoolDay.schoolDate];
                                                       NSString *thatDateString = [dateFormatter stringFromDate:dateFromString];
                                                       NSString *todayDateString = [dateFormatter stringFromDate:[NSDate date]];
                                                       NSString *actual = [day stringFromDate:dateFromString];
                                                       if ([todayDateString isEqualToString:thatDateString]) {
                                                            dayLabel.text = [@"Today is " stringByAppendingString:scheduleType.fullScheduleString];
                                                       } else {
                                                            dayLabel.text = [self.vacationString stringByAppendingString:[[actual stringByAppendingString:@" - "] stringByAppendingString:scheduleType.fullScheduleString]];
                                                            dayLabel.textColor = [UIColor redColor];
                                                       }
                                                       if (scheduleType.alertNeeded == YES) {
                                                            dayLabel.textColor = [UIColor redColor];
                                                       }
                                                       [dayLabel setFont:[UIFont systemFontOfSize:22]];
                                                       dayLabel.lineBreakMode = NSLineBreakByWordWrapping;
                                                       dayLabel.numberOfLines = 0;
                                                       [dayLabel sizeToFit];
                                                       [dayLabel setTextAlignment:UITextAlignmentCenter];
                                                       dayLabel.frame = CGRectMake(self.view.frame.size.width / 2 - dayLabel.frame.size.width / 2, dayLabel.frame.origin.y, dayLabel.frame.size.width, dayLabel.frame.size.height);
                                                       [scrollView addSubview:dayLabel];
                                                       
                                                       scheduleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, dayLabel.frame.origin.y + dayLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
                                                       scheduleLabel.text = scheduleType.scheduleString;
                                                       [scheduleLabel setFont:[UIFont systemFontOfSize:14]];
                                                       scheduleLabel.numberOfLines = 0;
                                                       [scheduleLabel sizeToFit];
                                                       [scheduleLabel setTextAlignment:UITextAlignmentCenter];
                                                       scheduleLabel.frame = CGRectMake(self.view.frame.size.width / 2 - scheduleLabel.frame.size.width / 2, scheduleLabel.frame.origin.y, scheduleLabel.frame.size.width, scheduleLabel.frame.size.height);
                                                       [scrollView addSubview:scheduleLabel];
                                                       
                                                       [self getAlertStringMethodWithCompletion:^(NSError *error, NSString *eventString) {
                                                            
                                                            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, scheduleLabel.frame.origin.y + scheduleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                            separator.backgroundColor = [UIColor blackColor];
                                                            [scrollView addSubview:separator];
                                                            
                                                            messageLabelA = [[UILabel alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                            UIFont *font = [UIFont systemFontOfSize:14];
                                                            [messageLabelA setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                            if (! [eventString isEqualToString:@"No recent alerts."]) {
                                                                 messageLabelA.text = @"Recent Alerts (VIEW ALL)";
                                                            } else {
                                                                 messageLabelA.text = @"Recent Alerts";
                                                            }
                                                            messageLabelA.lineBreakMode = NSLineBreakByWordWrapping;
                                                            messageLabelA.numberOfLines = 0;
                                                            [messageLabelA sizeToFit];
                                                            messageLabelA.frame = CGRectMake(self.view.frame.size.width / 2 - messageLabelA.frame.size.width / 2, messageLabelA.frame.origin.y, messageLabelA.frame.size.width, messageLabelA.frame.size.height);
                                                            [scrollView addSubview:messageLabelA];
                                                            
                                                            if (! [eventString isEqualToString:@"No recent alerts."]) {
                                                                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Recent Alerts (VIEW ALL)" attributes:nil];
                                                                 NSRange linkRange = NSMakeRange(14, 10); // for the word "link" in the string above
                                                                 
                                                                 NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                                                                                   NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
                                                                 [attributedString setAttributes:linkAttributes range:linkRange];
                                                                 
                                                                      // Assign attributedText to UILabel
                                                                 messageLabelA.attributedText = attributedString;
                                                                 UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertOpen)];
                                                                      // if labelView is not set userInteractionEnabled, you must do so
                                                                 [messageLabelA setUserInteractionEnabled:YES];
                                                                 [messageLabelA addGestureRecognizer:gesture];
                                                            }
                                                            
                                                            messageLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, messageLabelA.frame.origin.y + messageLabelA.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                            messageLabelB.text = [eventString copy];
                                                            messageLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                            messageLabelB.editable = false;
                                                            messageLabelB.scrollEnabled = false;
                                                            [messageLabelB setFont:[UIFont systemFontOfSize:16]];
                                                            [messageLabelB sizeToFit];
                                                            [scrollView addSubview:messageLabelB];
                                                            
                                                            UIView *separatorX = [[UIView alloc] initWithFrame:CGRectMake(10, messageLabelB.frame.origin.y + messageLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                            separatorX.backgroundColor = [UIColor blackColor];
                                                            [scrollView addSubview:separatorX];
                                                            
                                                            [self getEventStringMethodWithCompletion:^(NSError *error, NSString *eventString) {
                                                                 if (error != nil) {
                                                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Tap refresh button to try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                                      [alertView show];
                                                                      dispatch_async(dispatch_get_main_queue(), ^ {
                                                                           [activity stopAnimating];
                                                                           [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                                           UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewWillAppear:)];
                                                                           self.navigationItem.rightBarButtonItem = barButtonItem;
                                                                           [activity startAnimating];
                                                                           [barButtonItem release];
                                                                           [self showBadImage];
                                                                      });
                                                                 } else {
                                                                      messageLabelC = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorX.frame.origin.y + separatorX.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                      UIFont *font = [UIFont systemFontOfSize:14];
                                                                      [messageLabelC setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                                      if (! [eventString isEqualToString:@"No upcoming events."]) {
                                                                           messageLabelC.text = @"Upcoming Events (VIEW ALL)";
                                                                      } else {
                                                                           messageLabelC.text = @"Upcoming Events";
                                                                      }
                                                                      messageLabelC.lineBreakMode = NSLineBreakByWordWrapping;
                                                                      messageLabelC.numberOfLines = 0;
                                                                      [messageLabelC sizeToFit];
                                                                      messageLabelC.frame = CGRectMake(self.view.frame.size.width / 2 - messageLabelC.frame.size.width / 2, messageLabelC.frame.origin.y, messageLabelC.frame.size.width, messageLabelC.frame.size.height);
                                                                      [scrollView addSubview:messageLabelC];
                                                                      
                                                                      if (! [eventString isEqualToString:@"No upcoming events."]) {
                                                                           NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Upcoming Events (VIEW ALL)" attributes:nil];
                                                                           NSRange linkRange = NSMakeRange(16, 10); // for the word "link" in the string above
                                                                           
                                                                           NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                                                                                             NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
                                                                           [attributedString setAttributes:linkAttributes range:linkRange];
                                                                           
                                                                                // Assign attributedText to UILabel
                                                                           messageLabelC.attributedText = attributedString;
                                                                           UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventsOpen)];
                                                                                // if labelView is not set userInteractionEnabled, you must do so
                                                                           [messageLabelC setUserInteractionEnabled:YES];
                                                                           [messageLabelC addGestureRecognizer:gesture];
                                                                      }
                                                                      
                                                                      messageLabelD = [[UITextView alloc] initWithFrame:CGRectMake(10, messageLabelC.frame.origin.y + messageLabelC.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                      messageLabelD.text = [eventString copy];
                                                                      messageLabelD.dataDetectorTypes = UIDataDetectorTypeLink;
                                                                      messageLabelD.editable = false;
                                                                      messageLabelD.scrollEnabled = false;
                                                                      [messageLabelD setFont:[UIFont systemFontOfSize:16]];
                                                                      [messageLabelD sizeToFit];
                                                                      [scrollView addSubview:messageLabelD];
                                                                      
                                                                      if ([hasImage integerValue] == 1) {
                                                                                //ADD IMAGE!!!
                                                                           [self getImageDataMethodWithCompletion:^(NSError *error, NSMutableArray *returnData) {
                                                                                
                                                                                imageData = [returnData objectAtIndex:0];
                                                                                UIImage *image = [[UIImage alloc] init];
                                                                                
                                                                                image = [UIImage imageWithData:imageData];
                                                                                
                                                                                UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, messageLabelD.frame.origin.y + messageLabelD.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                                                separator.backgroundColor = [UIColor blackColor];
                                                                                [scrollView addSubview:separator];
                                                                                
                                                                                imageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                                UIFont *font = [UIFont systemFontOfSize:14];
                                                                                [imageLabel setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                                                imageLabel.text = @"Picture of the Day";
                                                                                imageLabel.lineBreakMode = NSLineBreakByWordWrapping;
                                                                                imageLabel.numberOfLines = 0;
                                                                                [imageLabel sizeToFit];
                                                                                imageLabel.frame = CGRectMake(self.view.frame.size.width / 2 - imageLabel.frame.size.width / 2, imageLabel.frame.origin.y, imageLabel.frame.size.width, imageLabel.frame.size.height);
                                                                                [scrollView addSubview:imageLabel];
                                                                                
                                                                                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 300)];
                                                                                
                                                                                if (image.size.width > self.view.frame.size.width - 20) {
                                                                                     image = [[AppManager getInstance] imageFromImage:image scaledToWidth:self.view.frame.size.width - 20];
                                                                                }
                                                                                imageView.image = image;
                                                                                [imageView sizeToFit];
                                                                                imageView.frame = CGRectMake(self.view.frame.size.width / 2 - imageView.frame.size.width / 2, imageLabel.frame.origin.y + imageLabel.frame.size.height + 10, imageView.frame.size.width, imageView.frame.size.height);
                                                                                [scrollView addSubview:imageView];
                                                                                
                                                                                imageLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                                [imageLabelB setFont:[UIFont systemFontOfSize:16]];
                                                                                imageLabelB.text = schoolDay.imageString;
                                                                                imageLabelB.editable = false;
                                                                                imageLabelB.scrollEnabled = false;
                                                                                imageLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                                                [imageLabelB sizeToFit];
                                                                                [scrollView addSubview:imageLabelB];
                                                                                
                                                                                UIView *separatorY = [[UIView alloc] initWithFrame:CGRectMake(10, imageLabelB.frame.origin.y + imageLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                                                separatorY.backgroundColor = [UIColor blackColor];
                                                                                [scrollView addSubview:separatorY];
                                                                                
                                                                                lunchLabelA = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorY.frame.origin.y + separatorY.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                                [lunchLabelA setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                                                lunchLabelA.text = @"Food";
                                                                                lunchLabelA.lineBreakMode = NSLineBreakByWordWrapping;
                                                                                lunchLabelA.numberOfLines = 0;
                                                                                [lunchLabelA sizeToFit];
                                                                                lunchLabelA.frame = CGRectMake(self.view.frame.size.width / 2 - lunchLabelA.frame.size.width / 2, lunchLabelA.frame.origin.y, lunchLabelA.frame.size.width, lunchLabelA.frame.size.height);
                                                                                [scrollView addSubview:lunchLabelA];
                                                                                
                                                                                lunchLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, lunchLabelA.frame.origin.y + lunchLabelA.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                                NSString *lunch = @"Lunch: ";
                                                                                lunchLabelB.text = [@"Breakfast: " stringByAppendingString:[[[schoolDay.breakfastString stringByAppendingString:@"\n\n"] stringByAppendingString:lunch] stringByAppendingString:schoolDay.lunchString]];
                                                                                lunchLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                                                lunchLabelB.editable = false;
                                                                                lunchLabelB.scrollEnabled = false;
                                                                                [lunchLabelB setFont:[UIFont systemFontOfSize:16]];
                                                                                [lunchLabelB sizeToFit];
                                                                                [scrollView addSubview:lunchLabelB];
                                                                                
                                                                                self.automaticallyAdjustsScrollViewInsets = NO;
                                                                                UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 120, 0);
                                                                                scrollView.contentInset = adjustForTabbarInsets;
                                                                                scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                                                                                CGRect contentRect = CGRectZero;
                                                                                for (UIView *view in scrollView.subviews) {
                                                                                     contentRect = CGRectUnion(contentRect, view.frame);
                                                                                }
                                                                                scrollView.contentSize = contentRect.size;
                                                                                
                                                                                [self.view addSubview:scrollView];
                                                                                
                                                                                [activity stopAnimating];
                                                                           }];
                                                                      }
                                                                      else {
                                                                           
                                                                           UIView *separatorY = [[UIView alloc] initWithFrame:CGRectMake(10, messageLabelD.frame.origin.y + messageLabelD.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                                                                           separatorY.backgroundColor = [UIColor blackColor];
                                                                           [scrollView addSubview:separatorY];
                                                                           
                                                                           lunchLabelA = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorY.frame.origin.y + separatorY.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                           [lunchLabelA setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
                                                                           lunchLabelA.text = @"Food";
                                                                           lunchLabelA.lineBreakMode = NSLineBreakByWordWrapping;
                                                                           lunchLabelA.numberOfLines = 0;
                                                                           [lunchLabelA sizeToFit];
                                                                           lunchLabelA.frame = CGRectMake(self.view.frame.size.width / 2 - lunchLabelA.frame.size.width / 2, lunchLabelA.frame.origin.y, lunchLabelA.frame.size.width, lunchLabelA.frame.size.height);
                                                                           [scrollView addSubview:lunchLabelA];
                                                                           
                                                                           lunchLabelB = [[UITextView alloc] initWithFrame:CGRectMake(10, lunchLabelA.frame.origin.y + lunchLabelA.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                                                                           NSString *lunch = @"Lunch: ";
                                                                           lunchLabelB.text = [@"Breakfast: " stringByAppendingString:[[[schoolDay.breakfastString stringByAppendingString:@"\n\n"] stringByAppendingString:lunch] stringByAppendingString:schoolDay.lunchString]];
                                                                           lunchLabelB.dataDetectorTypes = UIDataDetectorTypeLink;
                                                                           lunchLabelB.editable = false;
                                                                           lunchLabelB.scrollEnabled = false;
                                                                           [lunchLabelB setFont:[UIFont systemFontOfSize:16]];
                                                                           [lunchLabelB sizeToFit];
                                                                           [scrollView addSubview:lunchLabelB];
                                                                           
                                                                           self.automaticallyAdjustsScrollViewInsets = NO;
                                                                           UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 120, 0);
                                                                           scrollView.contentInset = adjustForTabbarInsets;
                                                                           scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                                                                           CGRect contentRect = CGRectZero;
                                                                           for (UIView *view in scrollView.subviews) {
                                                                                contentRect = CGRectUnion(contentRect, view.frame);
                                                                           }
                                                                           scrollView.contentSize = contentRect.size;
                                                                           
                                                                           [self.view addSubview:scrollView];
                                                                           
                                                                           [activity stopAnimating];
                                                                      }
                                                                 }
                                                            }];
                                                       }];
                                                  }
                                             } forType:schoolDay.scheduleType];
                                        }
                                   }
                              }];
                         }
                    }];
               }
          }];
          
          [self getMessageStringMethodWithCompletion:^(NSError *error, NSString *messageString) {
               if (! [messageString isEqualToString:@"None."]) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:messageString delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles: nil];
                    [alert show];
               }
          }];
          
     } else if ((! loadString || [loadString isEqual:@"1"] == true) && connected == false) {
          
          if (scrollView) {
               [scrollView removeFromSuperview];
          }
          scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
          
          self.navigationController.navigationBar.translucent = NO;
          
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"No network connection detected. Tap refresh button to try again. No network connection will prevent many app services from working properly." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
          [alertView show];
          
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewWillAppear:)];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [barButtonItem release];
          
          [self showBadImage];
     }
     
     
}

- (void)alertOpen {
     self.tabBarController.selectedIndex = 2;
}

- (void)eventsOpen {
     EventsTableViewController *controller = [[EventsTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
     [self.navigationController pushViewController:controller animated:YES];
}

- (void)showBadImage {
     
     theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 300)];
     
     UIImage *image = [UIImage imageNamed:@"logoLarge.jpeg"];
     
     if (image.size.width > self.view.frame.size.width - 20) {
          image = [[AppManager getInstance] imageFromImage:image scaledToWidth:self.view.frame.size.width - 20];
     }
     theImageView.image = image;
     [theImageView sizeToFit];
     theImageView.frame = CGRectMake(self.view.frame.size.width / 2 - theImageView.frame.size.width / 2, 10, theImageView.frame.size.width, theImageView.frame.size.height);
     
     [scrollView addSubview:theImageView];
     
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 120, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     
     [self.view addSubview:scrollView];
}

- (void)getImageDataMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnData))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [SchoolDayStructure query];
     [query whereKey:@"schoolDayID" equalTo:schoolDay.schoolDayID];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          SchoolDayStructure *structure = (SchoolDayStructure *)object;
          PFFile *imageFile = structure.imageFile;
          [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
               theError = error;
               [array addObject:data];
               dispatch_group_leave(serviceGroup);
          }];
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, array);
     });
}

-(NSString *)addSuffixToNumber:(int) number
{
     NSString *suffix;
     int ones = number % 10;
     int tens = (number/10) % 10;
     
     if (tens ==1) {
          suffix = @"th";
     } else if (ones ==1){
          suffix = @"st";
     } else if (ones ==2){
          suffix = @"nd";
     } else if (ones ==3){
          suffix = @"rd";
     } else {
          suffix = @"th";
     }
     
     NSString * completeAsString = [NSString stringWithFormat:@"%d%@", number, suffix];
     return completeAsString;
}

- (void)viewDidLoad {
	[super viewDidLoad];
     
#if !(TARGET_IPHONE_SIMULATOR)
     
          //Only run on actual device
     
#endif
     
     NSString *loadString = [[NSUserDefaults standardUserDefaults] objectForKey:@"reloadHomePage"];
     if ([loadString isEqual:@"0"]) {
          [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
          [[NSUserDefaults standardUserDefaults] synchronize];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewWillAppear:)];
          self.navigationItem.rightBarButtonItem = barButtonItem;
     }
     
     if (connected == true && connected) {
          [self getCountMethodWithCompletion:^(NSInteger count) {
               NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"];
               NSInteger read = array.count;
               NSNumber *number = [NSNumber numberWithInt:(count - read)];
               [self getCountTwoMethodWithCompletion:^(NSInteger count2) {
                    NSNumber *updates = [NSNumber numberWithInt:count2];
                    NSNumber *updatesSeen = [[NSUserDefaults standardUserDefaults] objectForKey:@"ECviewed"];
                    if (updatesSeen) {
                         if ([updatesSeen integerValue] >= [updates integerValue]) {
                              updates = [NSNumber numberWithInt:0];
                         } else {
                              updates = [NSNumber numberWithInt:[updates integerValue] - [updatesSeen integerValue]];
                         }
                    } else {
                         updates = [NSNumber numberWithInt:[updates integerValue] - [updatesSeen integerValue]];
                    }
                    [self getCountThreeMethodWithCompletion:^(NSInteger count3) {
                         NSMutableArray *SCarray = [[NSUserDefaults standardUserDefaults] objectForKey:@"answeredPolls"];
                         NSInteger answered = SCarray.count;
                         NSNumber *secondNumber = [NSNumber numberWithInt:(count3 - answered)];
                         NSInteger final = [number integerValue] + [updates integerValue] + [secondNumber integerValue];
                         if (final > 0) {
                              [[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = [[NSNumber numberWithInt:final] stringValue];
                         }
                         else
                              [[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = nil;
                         [self getCountFourMethodWithCompletion:^(NSInteger count4) {
                              NSMutableArray *alertsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"];
                              NSInteger read = alertsArray.count;
                              NSNumber *readNumber = [NSNumber numberWithInt:(count4 - read)];
                              if ([readNumber integerValue] > 0) {
                                   [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = [readNumber stringValue];
                              }
                              else
                                   [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = nil;
                         }];
                    }];
               }];
               
          }];
     }
}

- (void)postPicture {
     
}

- (NSString *)getDayFromInteger:(int)day {
     switch (day) {
          case 1:
               return @"Monday";
               break;
          
          case 2:
               return @"Tuesday";
               break;
          
          case 3:
               return @"Wednesday";
               break;
          
          case 4:
               return @"Thursday";
               break;
               
          case 5:
               return @"Friday";
               break;
          
          default:
               return nil;
               break;
     }
}

- (void)getPasswordStringMethodWithCompletion:(void (^)(NSError *error, NSString *passwordString))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSString *theString;
     PFQuery *query = [SpecialKeyStructure query];
     [query whereKey:@"key" equalTo:@"appActive"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          theString = [[object objectForKey:@"password"] copy];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, theString);
     });
}

- (void)getMessageStringMethodWithCompletion:(void (^)(NSError *error,NSString *messageString))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSString *theString;
     PFQuery *query = [SpecialKeyStructure query];
     [query whereKey:@"key" equalTo:@"appMessage"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          theString = [[object objectForKey:@"value"] copy];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, theString);
     });
}

- (void)getStatusStringMethodWithCompletion:(void (^)(NSError *error, NSString *eventString, NSString *messageString))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSString *theString;
     __block NSString *message;
     PFQuery *query = [SpecialKeyStructure query];
     [query whereKey:@"key" equalTo:@"appActive"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          theString = [[object objectForKey:@"value"] copy];
          message = [[object objectForKey:@"message"] copy];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, theString, message);
     });
}

- (void)getModeStringMethodWithCompletion:(void (^)(NSError *error, NSString *eventString))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSString *theString;
     PFQuery *query = [SpecialKeyStructure query];
     [query whereKey:@"key" equalTo:@"scheduleMode"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          theString = [[object objectForKey:@"value"] copy];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, theString);
     });
}

- (void)getEventStringMethodWithCompletion:(void (^)(NSError *error, NSString *eventString))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSString *theString;
     PFQuery *query = [EventStructure query];
     [query whereKey:@"isApproved" equalTo:[NSNumber numberWithInteger:1]];
     [query orderByAscending:@"eventDate"];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          theError = error;
          NSString *eventString = @"No upcoming events.";
          if (objects.count == 0) {
               theString = [eventString copy];
               dispatch_group_leave(serviceGroup);
          } else {
               for (int i = 0; i < objects.count; i++) {
                    EventStructure *event = (EventStructure *)[objects objectAtIndex:i];
                    if ([self daysBetweenDate:[NSDate date] andDate:event.eventDate] == 0) {
                         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                         [formatter setDateFormat:@"h:mm a"];
                         NSString *timeString = [NSString stringWithFormat:@"* [%@] ",
                                                  [formatter stringFromDate:event.eventDate]];
                         if ([eventString isEqualToString:@"No upcoming events."]) {
                              eventString = [timeString stringByAppendingString:[event.titleString copy]];
                         } else
                              eventString = [[[eventString stringByAppendingString:@"\n\n"] stringByAppendingString:timeString] stringByAppendingString:event.titleString];
                    } else if ([self daysBetweenDate:[NSDate date] andDate:event.eventDate] <= 3) {
                         if ([eventString isEqualToString:@"No upcoming events."]) {
                              eventString = [event.titleString copy];
                         } else
                              eventString = [[eventString stringByAppendingString:@"\n\n"] stringByAppendingString:event.titleString];
                    }
                    if (i == objects.count - 1) {
                         theString = [eventString copy];
                         dispatch_group_leave(serviceGroup);
                    }
               }
          }
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, theString);
     });
}

- (void)getAlertStringMethodWithCompletion:(void (^)(NSError *error, NSString *eventString))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSString *theString;
     PFQuery *query = [AlertStructure query];
     [query whereKey:@"isReady" equalTo:[NSNumber numberWithInteger:1]];
     [query orderByDescending:@"createdAt"];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          theError = error;
          NSString *eventString = @"No recent alerts.";
          if (objects.count == 0) {
               theString = [eventString copy];
               dispatch_group_leave(serviceGroup);
          } else {
               for (int i = 0; i < objects.count; i++) {
                    AlertStructure *alert = (AlertStructure *)[objects objectAtIndex:i];
                    if ([self daysBetweenDate:alert.createdAt andDate:[NSDate date]] <= 3) {
                         if ([eventString isEqualToString:@"No recent alerts."]) {
                              eventString = [alert.titleString copy];
                         } else
                              eventString = [[eventString stringByAppendingString:@"\n\n"] stringByAppendingString:alert.titleString];
                    }
                    if (i == objects.count - 1) {
                         theString = [eventString copy];
                         dispatch_group_leave(serviceGroup);
                    }
               }
          }
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, theString);
     });
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
     NSDate *fromDate;
     NSDate *toDate;
     
     NSCalendar *calendar = [NSCalendar currentCalendar];
     
     [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                  interval:NULL forDate:fromDateTime];
     [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                  interval:NULL forDate:toDateTime];
     
     NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                fromDate:fromDate toDate:toDate options:0];
     
     return [difference day];
}

- (void)getScheduleStringMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *schedule))completion forType:(NSString *)string {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *schedule = [NSMutableArray array];
     PFQuery *query = [ScheduleType query];
     [query whereKey:@"typeID" equalTo:string];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          [schedule addObjectsFromArray:objects];
          theError = error;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, schedule);
     });
}

- (void)getCurrentSchoolDayMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *schoolDay))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [SchoolDayStructure query];
     [query orderByAscending:@"schoolDayID"];
     [query whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          theError = error;
          [array addObjectsFromArray:objects];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, array);
     });
}

- (void)getCurrentLunchMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *schoolDay))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [LunchMenusStructure query];
     [query orderByAscending:@"lunchStructureID"];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          theError = error;
          [array addObjectsFromArray:objects];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, array);
     });
}

- (void)getCountFourMethodWithCompletion:(void (^)(NSInteger count))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     PFQuery *query = [AlertStructure query];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(count);
     });
}

- (void)getCountThreeMethodWithCompletion:(void (^)(NSInteger count))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     PFQuery *query = [PollStructure query];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(count);
     });
}

- (void)getCountTwoMethodWithCompletion:(void (^)(NSInteger count))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     PFQuery *query = [ExtracurricularUpdateStructure query];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(count);
     });
}

- (void)getCountMethodWithCompletion:(void (^)(NSInteger count))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"isApproved" equalTo:[NSNumber numberWithInteger:1]];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(count);
     });
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
