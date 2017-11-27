//
//  AppDelegate.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/17/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ExtracurricularUpdateStructure.h"
#import "CommunityServiceStructure.h"
#import "NewsArticleStructure.h"
#import "AlertStructure.h"
#import "SchoolDayStructure.h"
#import "ScheduleType.h"
#import "AlertDetailViewController.h"
#import "NewsArticleDetailViewController.h"
#import "SpecialKeyStructure.h"
#import "ErrorStructure.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "ScholarshipStructure.h"
#import "Utils.h"

@implementation AppDelegate {
     BOOL connected;
}

void uncaughtExceptionHandler(NSException *exception) {
     
     NSString *deviceToken = [[PFInstallation currentInstallation] objectForKey:@"deviceToken"];
     if (! deviceToken) {
          deviceToken = @"No device token available.";
     }
     NSString *username;
     if ([PFUser currentUser]) {
          username = [[PFUser currentUser] username];
     } else
          username = @"No username available.";
     NSArray *callStackArray = [exception callStackSymbols];
     NSString *callStack = [[callStackArray valueForKey:@"description"] componentsJoinedByString:@""];
     NSString *reason = [[exception.name stringByAppendingString:@" - "] stringByAppendingString:exception.reason];
     NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
     [dictionary setObject:deviceToken forKey:@"deviceToken"];
     [dictionary setObject:username forKey:@"username"];
     [dictionary setObject:callStack forKey:@"stack"];
     [dictionary setObject:reason forKey:@"message"];
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:nil error:nil];
     NSString* string = [NSString stringWithUTF8String:[jsonData bytes]].description;
     NSArray *copyArray = [[NSArray alloc] initWithObjects:string, nil];
     [[NSUserDefaults standardUserDefaults] setObject:copyArray forKey:@"errorsArray"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
     
     [Utils init];
     
          //TODO - Encrypt and configure all values!!!
     
     [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
          configuration.applicationId = [Utils decrypt:[Utils getConfigurationForKey:@"appId"]];
          configuration.clientKey = @"";
          configuration.server = [Utils decrypt:[Utils getConfigurationForKey:@"serverURL"]];
     }]];
     
     [PFUser enableRevocableSessionInBackground];
     
     Reachability *reachability = [Reachability reachabilityForInternetConnection];
     NetworkStatus networkStatus = [reachability currentReachabilityStatus];
     connected = (networkStatus != NotReachable);
     
     if (connected && [PFInstallation currentInstallation]) {
          [[PFInstallation currentInstallation] fetchIfNeededInBackground];
     }
     
     NSMutableArray *errorsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"errorsArray"] mutableCopy];
     if (! errorsArray) {
          errorsArray = [NSMutableArray array];
     } else if (errorsArray.count > 0 && connected == true) {
          NSMutableArray *copyArray = [errorsArray mutableCopy];
          for (NSString *object in errorsArray) {
               [copyArray removeObject:object];
               [Utils logString:object forObjects:nil forLevel:@"error"];
          }
          [[NSUserDefaults standardUserDefaults] setObject:copyArray forKey:@"errorsArray"];
          [[NSUserDefaults standardUserDefaults] synchronize];
     }
     
     UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                     UIUserNotificationTypeBadge |
                                                     UIUserNotificationTypeSound);
     UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                              categories:nil];
     
     if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
     {
               // iOS 8 Notifications
          [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
          
          [application registerForRemoteNotifications];
     }
     else
     {
               // iOS < 8 Notifications
          [application registerForRemoteNotificationTypes:
           (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
     }
     
          //NSArray *array = [NSArray array];
     
          //NSLog(@"%@", [array objectAtIndex:2]);
     
     NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
     
     if (connected == true) {
          if (notificationPayload) {
               if ([notificationPayload objectForKey:@"a"]) {
                    self.alertString = [notificationPayload objectForKey:@"a"];
                    [self getAlertForIDMethodWithCompletion:^(NSMutableArray *array, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^ {
                              [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadAlertsPage"];
                              NSMutableArray *readArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"] mutableCopy];
                              if (! readArray) {
                                   readArray = [[NSMutableArray alloc] init];
                              }
                              [readArray addObject:self.alertString];
                              [[NSUserDefaults standardUserDefaults] setObject:readArray forKey:@"readAlerts"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                              AlertStructure *theAlert = [[AlertStructure alloc] init];
                              theAlert.titleString = [[array firstObject] objectForKey:@"titleString"];
                              theAlert.authorString = [[array firstObject] objectForKey:@"authorString"];
                              theAlert.alertTime = [[array firstObject] objectForKey:@"alertTime"];
                              theAlert.contentString = [[array firstObject] objectForKey:@"contentString"];
                              theAlert.hasTime = [[array firstObject] objectForKey:@"hasTime"];
                              theAlert.dateString = [[array firstObject] objectForKey:@"dateString"];
                              theAlert.isReady = [[array firstObject] objectForKey:@"isReady"];
                              theAlert.alertID = [[array firstObject] objectForKey:@"alertID"];
                              AlertDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlertDetail"];
                              controller.alert = theAlert;
                              controller.showCloseButton = YES;
                              UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
                              UINavigationController *navigationController =
                              [[UINavigationController alloc] initWithRootViewController:controller];
                              [nav presentViewController:navigationController animated:YES completion:^{}];
                         });
                    } forID:self.alertString];
               } else if ([notificationPayload objectForKey:@"n"]) {
                    self.newsString = [notificationPayload objectForKey:@"n"];
                    [self getNewsForIDMethodWithCompletion:^(NSMutableArray *array, NSError *error) {
                         dispatch_async(dispatch_get_main_queue(), ^ {
                              NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
                              if (! pagesArray) {
                                   pagesArray = [[NSMutableArray alloc] init];
                              } else {
                                   if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)0]]) {
                                        [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)0]];
                                        [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                   }
                              }
                              NSMutableArray *readArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"] mutableCopy];
                              if (! readArray) {
                                   readArray = [[NSMutableArray alloc] init];
                              }
                              [readArray addObject:self.newsString];
                              [[NSUserDefaults standardUserDefaults] setObject:readArray forKey:@"readNewsArticles"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                              
                              NewsArticleStructure *theNews = [[NewsArticleStructure alloc] init];
                              theNews.titleString = [[array firstObject] objectForKey:@"titleString"];
                              theNews.summaryString = [[array firstObject] objectForKey:@"summaryString"];
                              theNews.authorString = [[array firstObject] objectForKey:@"authorString"];
                              theNews.dateString = [[array firstObject] objectForKey:@"dateString"];
                              theNews.contentURLString = [[array firstObject] objectForKey:@"contentURLString"];
                              theNews.articleID = [[array firstObject] objectForKey:@"articleID"];
                              theNews.likes = [[array firstObject] objectForKey:@"likes"];
                              theNews.views = [[array firstObject] objectForKey:@"views"];
                              theNews.hasImage = [[array firstObject] objectForKey:@"hasImage"];
                              
                              if (theNews.hasImage == [NSNumber numberWithInt:0]) {
                                        //Get the image data...
                                   [self getImageDataMethodWithCompletion:^(NSError *error, NSMutableArray *returnData) {
                                        NewsArticleDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NADetail"];
                                        controller.NA = theNews;
                                        controller.imageData = [returnData objectAtIndex:0];
                                        controller.showCloseButton = YES;
                                        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
                                        UINavigationController *navigationController =
                                        [[UINavigationController alloc] initWithRootViewController:controller];
                                        [nav presentViewController:navigationController animated:YES completion:^{}];
                                   } forID:theNews.articleID];
                              } else {
                                   NewsArticleDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NADetail"];
                                   controller.NA = theNews;
                                   controller.imageData = [[NSData alloc] init];
                                   controller.showCloseButton = YES;
                                   UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
                                   UINavigationController *navigationController =
                                   [[UINavigationController alloc] initWithRootViewController:controller];
                                   [nav presentViewController:navigationController animated:YES completion:^{}];
                              }
                         });
                    } forID:self.newsString];
               } else if ([notificationPayload objectForKey:@"c"]) {
                    NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
                    if (! pagesArray) {
                         pagesArray = [[NSMutableArray alloc] init];
                    } else {
                         if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)2]]) {
                              [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)2]];
                              [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                         }
                    }
               } else if ([notificationPayload objectForKey:@"e"]) {
                    NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
                    if (! pagesArray) {
                         pagesArray = [[NSMutableArray alloc] init];
                    } else {
                         if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)1]]) {
                              [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)1]];
                              [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                         }
                    }
               } else if ([notificationPayload objectForKey:@"p"]) {
                    NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
                    if (! pagesArray) {
                         pagesArray = [[NSMutableArray alloc] init];
                    } else {
                         if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)3]]) {
                              [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)3]];
                              [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                         }
                    }
               }
          }
     }
     
     /*if (application.applicationState != UIApplicationStateBackground) {
               // Track an app open here if we launch with a push, unless
               // "content_available" was used to trigger a background push (introduced
               // in iOS 7). In that case, we skip tracking here to avoid double
               // counting the app-open.
          BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
          BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
          BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
          if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
               [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
          }
     }*/
     
    /*CommunityServiceStructure *TestOne = [[CommunityServiceStructure alloc] init];
    TestOne.commDateString = @"SampleDate";
    CommunityServiceStructure *TestTwo = [[CommunityServiceStructure alloc] init];
    TestTwo.commPreviewString = @"PreviewCheck";
    CommunityServiceStructure *TestThree = [[CommunityServiceStructure alloc] init];
    TestThree.commSummaryString = @"SummaryCheck";
    CommunityServiceStructure *TestFour = [[CommunityServiceStructure alloc] init];
    TestFour.commTitleString = @"SampleTitle";
    TestOne.IsNewNumber = [NSNumber numberWithInt:1];
    
    [TestOne saveInBackground];
    [TestTwo saveInBackground];
    [TestThree saveInBackground];
    [TestFour saveInBackground];

    //***Image not tested****/
     
              ExtracurricularUpdateStructure *EC;
     /*@property NSString *titleString;
      @property NSArray *descriptionString;
      @property NSNumber *hasImage;
      @property PFFile *imageFile;
      @property NSString *imageURLString;
      @property NSString *meetingString;
      @property NSDictionary *contactInformationDictionary;
      @property NSString *extracurricularIDString;*/
     /*for (int i = 0; i < 10; i++) {
          EC = [[ExtracurricularUpdateStructure alloc] init];
          EC.extracurricularID = [NSNumber numberWithInt:i];
          EC.messageString = @"sflsjf";
          EC.extracurricularUpdateID = [NSNumber numberWithInt:i];
          [EC saveInBackground];
     }*/
     
     /*ExtracurricularStructure *extracurricularStructure;
     for (int i = 0; i < 10; i++) {
          extracurricularStructure = [[ExtracurricularStructure alloc] init];
          extracurricularStructure.titleString = @"sjflsjf";
          extracurricularStructure.descriptionString = @"descjfs";
          extracurricularStructure.hasImage = [NSNumber numberWithInt:1];
          UIImage *image = [UIImage imageNamed:@"theNews@2x.png"];
          NSData *data = UIImagePNGRepresentation(image);
          PFFile *imageFile = [PFFile fileWithData:data];
          extracurricularStructure.imageFile = imageFile;
          extracurricularStructure.imageURLString = @"sfsdf";
          extracurricularStructure.meetingString = @"jflsjdf";
          extracurricularStructure.contactInformationDictionary = [[NSMutableDictionary alloc] init];
          extracurricularStructure.extracurricularID = [NSNumber numberWithInt:i];
          [extracurricularStructure saveInBackground];
     }*/
     
          //Saving new comm service
     
     /*@property NSString *commTitleString;
      @property NSString *commPreviewString;
      @property NSString *commDateString;
      @property NSString *commSummaryString;
      @property NSNumber *IsNewNumber;
      @property PFFile *commImageFile;
      @property NSNumber *hasImage;
      @property NSNumber *communityServiceID;*/
     
     /*CommunityServiceStructure *comm;
     for (int i = 0; i < 10; i++) {
          comm = [[CommunityServiceStructure alloc] init];
          comm.commTitleString = @"Test Title";
          comm.commPreviewString = @"sfslfjlsdjf";
          comm.commSummaryString = @"sfjsdfjlsd";
          comm.IsNewNumber = [NSNumber numberWithInt:1];
          NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"home@2x.png"]);
          PFFile *file = [PFFile fileWithData:data];
          comm.commImageFile = file;
          comm.hasImage = [NSNumber numberWithInt:1];
          comm.communityServiceID = [NSNumber numberWithInt:i];
          [comm saveInBackground];
     }
     
          //Saving new news articles...
     
     /*@property NSNumber *hasImage; // 0 = false, 1 = true
      @property PFFile *imageFile;
      @property NSString *titleString;
      @property NSString *summaryString;
      @property NSString *authorString;
      @property NSString *dateString;
      @property NSString *contentURLString;
      @property NSNumber *articleID;
      @property NSNumber *likes;
      @property NSString *imageURLString;*/
     
     /*NewsArticleStructure *news;
     for (int i = 0; i < 5; i++) {
          news = [[NewsArticleStructure alloc] init];
          news.hasImage = [NSNumber numberWithInt:1];
          NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"home@2x.png"]);
          PFFile *file = [PFFile fileWithData:data];
          news.imageFile = file;
          news.titleString = @"Test article...";
          news.summaryString = @"Summary goes here...";
          news.authorString = @"Kevin";
          news.dateString = @"Today!!!";
          news.contentURLString = @"sjflsdjf";
          news.articleID = [NSNumber numberWithInt:i];
          news.likes = [NSNumber numberWithInt:100];
          news.imageURLString = @"sjfsdlsjfsdf";
          [news saveInBackground];
     }*/
     
     /*UsefulLinkArray *districtPagesArray = [[UsefulLinkArray alloc] init];
     NSMutableArray *arrayOne = [[NSMutableArray alloc] init];
     districtPagesArray.headerTitle = @"DISTRICT PAGES";
     districtPagesArray.index = [NSNumber numberWithInt:0];
     arrayOne = [[NSMutableArray alloc] init];
     NSDictionary *dictionary = [[NSMutableDictionary alloc] init];
     [dictionary setValue:@"Weymouth Public Schools Website" forKey:@"titleString"];
     [dictionary setValue:@"http://www.weymouthschools.org" forKey:@"URLString"];
     [arrayOne addObject:dictionary];
     dictionary = [[NSMutableDictionary alloc] init];
     [dictionary setValue:@"Weymouth High School Website" forKey:@"titleString"];
     [dictionary setValue:@"http://www.weymouthschools.org/weymouth-high-school" forKey:@"URLString"];
     [arrayOne addObject:dictionary];
     districtPagesArray.linksArray = [arrayOne copy];
     [districtPagesArray saveInBackground];
     
     UsefulLinkArray *studentLoginsArray = [[UsefulLinkArray alloc] init];
     NSMutableArray *arrayTwo = [[NSMutableArray alloc] init];
     studentLoginsArray.headerTitle = @"STUDENT LOGINS";
     studentLoginsArray.index = [NSNumber numberWithInt:1];
     dictionary = [[NSMutableDictionary alloc] init];
     [dictionary setValue:@"X2 Portal" forKey:@"titleString"];
     [dictionary setValue:@"https://x2.weymouthschools.org/x2sis/logon.do" forKey:@"URLString"];
     [arrayTwo addObject:dictionary];
     dictionary = [[NSMutableDictionary alloc] init];
     [dictionary setValue:@"Student Webmail (Grades 11-12)" forKey:@"titleString"];
     [dictionary setValue:@"http://mail.weymouthstudents.org" forKey:@"URLString"];
     [arrayTwo addObject:dictionary];
     dictionary = [[NSMutableDictionary alloc] init];
     [dictionary setValue:@"Student Webmail (Grades 9-10)" forKey:@"titleString"];
     [dictionary setValue:@"https://accounts.google.com/Login" forKey:@"URLString"];
     [arrayTwo addObject:dictionary];
     dictionary = [[NSMutableDictionary alloc] init];
     [dictionary setValue:@"Naviance" forKey:@"titleString"];
     [dictionary setValue:@"https://connection.naviance.com/family-connection/auth/login/?hsid=weymouth" forKey:@"URLString"];
     [arrayTwo addObject:dictionary];
     studentLoginsArray.linksArray = [arrayTwo copy];
     [studentLoginsArray saveInBackground];*/
     
     /*LunchMenusStructure *lunch;
     for (int i = 0; i < 5; i++) {
          lunch = [[LunchMenusStructure alloc] init];
          lunch.breakfastString = @"Breakfast!";
          lunch.lunchString = @"Lunch!";
          lunch.dateString = @"Monday, September 14th";
          lunch.lunchStructureID = [NSNumber numberWithInt:i];
          [lunch saveInBackground];
     }*/
     
          //[PFUser logOutInBackground];
     
     /*AlertStructure *alertStructure = [[AlertStructure alloc] init];
     alertStructure.titleString = @"Test Alert";
     alertStructure.authorString = @"Kevin Lyons";
     alertStructure.dateString = @"Thursday, October 8th, 2015";
     alertStructure.contentString = @"This is a test content string for this alert!";
     [alertStructure saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
          if (! error) {
               NSLog(@"Here!!! Saved successfully without error.");
          }
     }];*/
     
          //[PFUser logOutInBackground];
     
     /*PollStructure *pollStructure = [[PollStructure alloc] init];
     pollStructure.pollTitle = @"Cell Phone Policy";
     pollStructure.pollQuestion = @"Do you think that students should be able to use cell phones in class all the time?";
     pollStructure.pollMultipleChoices = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"0", @"0", nil] forKeys:[NSArray arrayWithObjects:@"YES", @"NO", nil]];
     pollStructure.pollID = @"0";
     pollStructure.totalResponses = @"0";
     [pollStructure saveInBackground];*/
     
     /*SchoolDayStructure *schoolDayStructure = [[SchoolDayStructure alloc] init];
     schoolDayStructure.schoolDayID = @"0";
     schoolDayStructure.schoolDate = @"11-23-2015";
     schoolDayStructure.scheduleType = @"D";
     schoolDayStructure.messageString = @"No major events today.";
     schoolDayStructure.hasImage = YES;
     UIImage *image = [UIImage imageNamed:@"studentCenter@2x.png"];
     NSData *data = UIImagePNGRepresentation(image);
     schoolDayStructure.imageFile = [PFFile fileWithData:data];
     schoolDayStructure.imageString = @"None.";
     [schoolDayStructure saveInBackground];*/
     
     /*ScheduleType *scheduleType = [[ScheduleType alloc] init];
     scheduleType.typeID = @"F1";
     scheduleType.scheduleString = @"To be copied.";
     scheduleType.alertNeeded = YES;
     [scheduleType saveInBackground];*/
     
     /*UserRegisterStructure *URS = [[UserRegisterStructure alloc] init];
     URS.firstName = @"Joe";
     URS.lastName = @"Smith";
     URS.email = @"team@wildcatconnect.org";
     [URS saveInBackground];*/
     
     /*SpecialKeyStructure *SKS = [[SpecialKeyStructure alloc] init];
     SKS.key = @"doSDSD";
     SKS.value = @"1";
     [SKS saveInBackground];*/
     
     /*EventStructure *event = [[EventStructure alloc] init];
     event.titleString = @"Our First Event";
     event.locationString = @"Weymouth, MA";
     event.messageString = @"Be sure to bring your tickets!";
     event.eventDate = [NSDate date];
     [event saveInBackground];*/
     
     /*ScholarshipStructure *schol = [[ScholarshipStructure alloc] init];
     schol.titleString = @"Test Scholarship";
     schol.dueDate = [NSDate date];
     schol.messageString = @"Apply now!";
     schol.userString = @"Kevin Lyons";
     schol.email = @"team@wildcatconnect.org";
     [schol saveInBackground];*/
     
    return YES;
}
                                   
- (void)getImageDataMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnData))completion forID:(NSNumber *)ID {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"articleID" equalTo:ID];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          NewsArticleStructure *structure = (NewsArticleStructure *)object;
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
     PFInstallation *currentInstallation = [PFInstallation currentInstallation];
     [currentInstallation setDeviceTokenFromData:deviceToken];
     if (currentInstallation.channels.count == 0) {
          [currentInstallation setChannels:[NSArray arrayWithObjects:@"global", @"allNews", @"allCS", @"allPolls", nil]];
     }
     [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
     if (error.code == 3010) {
               //
     } else {
               //
     }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     if (alertView.tag == 0) {
          if (buttonIndex == 0) {
               [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadAlertsPage"];
               [[NSUserDefaults standardUserDefaults] synchronize];
          } else {
               [self getAlertForIDMethodWithCompletion:^(NSMutableArray *array, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadAlertsPage"];
                         NSMutableArray *readArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"] mutableCopy];
                         if (! readArray) {
                              readArray = [[NSMutableArray alloc] init];
                         }
                         [readArray addObject:self.alertString];
                         [[NSUserDefaults standardUserDefaults] setObject:readArray forKey:@"readAlerts"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         AlertStructure *theAlert = [[AlertStructure alloc] init];
                         theAlert.titleString = [[array firstObject] objectForKey:@"titleString"];
                         theAlert.authorString = [[array firstObject] objectForKey:@"authorString"];
                         theAlert.alertTime = [[array firstObject] objectForKey:@"alertTime"];
                         theAlert.contentString = [[array firstObject] objectForKey:@"contentString"];
                         theAlert.hasTime = [[array firstObject] objectForKey:@"hasTime"];
                         theAlert.dateString = [[array firstObject] objectForKey:@"dateString"];
                         theAlert.isReady = [[array firstObject] objectForKey:@"isReady"];
                         theAlert.alertID = [[array firstObject] objectForKey:@"alertID"];
                         AlertDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlertDetail"];
                         controller.alert = theAlert;
                         controller.showCloseButton = YES;
                         UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
                         UINavigationController *navigationController =
                         [[UINavigationController alloc] initWithRootViewController:controller];
                         [nav presentViewController:navigationController animated:YES completion:^{}];
                    });
               } forID:self.alertString];
          }
     } else if (alertView.tag == 1) {
          if (buttonIndex == 0) {
               NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
               if (! pagesArray) {
                    pagesArray = [[NSMutableArray alloc] init];
               } else {
                    if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)0]]) {
                         [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)0]];
                         [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                    }
               }
               NSMutableArray *readArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"] mutableCopy];
               if (! readArray) {
                    readArray = [[NSMutableArray alloc] init];
               }
               [readArray addObject:self.newsString];
               [[NSUserDefaults standardUserDefaults] setObject:readArray forKey:@"readNewsArticles"];
               [[NSUserDefaults standardUserDefaults] synchronize];
          } else {
               [self getNewsForIDMethodWithCompletion:^(NSMutableArray *array, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
                         if (! pagesArray) {
                              pagesArray = [[NSMutableArray alloc] init];
                         } else {
                              if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)0]]) {
                                   [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)0]];
                                   [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                              }
                         }
                         NSMutableArray *readArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"] mutableCopy];
                         if (! readArray) {
                              readArray = [[NSMutableArray alloc] init];
                         }
                         [readArray addObject:self.newsString];
                         [[NSUserDefaults standardUserDefaults] setObject:readArray forKey:@"readNewsArticles"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                         NewsArticleStructure *theNews = [[NewsArticleStructure alloc] init];
                         theNews.titleString = [[array firstObject] objectForKey:@"titleString"];
                         theNews.summaryString = [[array firstObject] objectForKey:@"summaryString"];
                         theNews.authorString = [[array firstObject] objectForKey:@"authorString"];
                         theNews.dateString = [[array firstObject] objectForKey:@"dateString"];
                         theNews.contentURLString = [[array firstObject] objectForKey:@"contentURLString"];
                         theNews.articleID = [[array firstObject] objectForKey:@"articleID"];
                         theNews.likes = [[array firstObject] objectForKey:@"likes"];
                         theNews.views = [[array firstObject] objectForKey:@"views"];
                         theNews.hasImage = [[array firstObject] objectForKey:@"hasImage"];
                         
                         if ([theNews.hasImage integerValue] == 1) {
                              [self getImageDataMethodWithCompletion:^(NSError *error, NSMutableArray *returnData) {
                                   NewsArticleDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NADetail"];
                                   controller.NA = theNews;
                                   controller.imageData = [returnData objectAtIndex:0];
                                   controller.showCloseButton = YES;
                                   UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
                                   UINavigationController *navigationController =
                                   [[UINavigationController alloc] initWithRootViewController:controller];
                                   [nav presentViewController:navigationController animated:YES completion:^{}];
                              } forID:theNews.articleID];
                         } else {
                              NewsArticleDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NADetail"];
                              controller.NA = theNews;
                              controller.imageData = [[NSData alloc] init];
                              controller.showCloseButton = YES;
                              UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
                              UINavigationController *navigationController =
                              [[UINavigationController alloc] initWithRootViewController:controller];
                              [nav presentViewController:navigationController animated:YES completion:^{}];
                         }
                    });
               } forID:self.newsString];
          }
     }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
     [PFPush handlePush:userInfo];
     self.alertString = [userInfo objectForKey:@"a"];
     if (self.alertString) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You have 1 new alert message. Would you like to read now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [alert setTag:0];
          [alert show];
          [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
          [[NSUserDefaults standardUserDefaults] synchronize];
     }
     self.newsString = [userInfo objectForKey:@"n"];
     if (self.newsString) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"News Article" message:@"You have 1 new article. Would you like to read now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [alert setTag:1];
          [alert show];
     }
     if ([userInfo objectForKey:@"c"]) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Community Service" message:@"You have 1 new community service opportunity. Navigate to the Community Service page to read." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alert setTag:2];
          [alert show];
          NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
          if (! pagesArray) {
               pagesArray = [[NSMutableArray alloc] init];
          } else {
               if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)2]]) {
                    [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)2]];
                    [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
               }
          }
     }
     if ([userInfo objectForKey:@"e"]) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Group Update" message:@"You have 1 new group update. Navigate to the Groups page to read." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alert setTag:3];
          [alert show];
          NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
          if (! pagesArray) {
               pagesArray = [[NSMutableArray alloc] init];
          } else {
               if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)1]]) {
                    [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)1]];
                    [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
               }
          }
     }
     if ([userInfo objectForKey:@"p"]) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Poll" message:@"You have 1 new user poll. Navigate to the Student Center page to cast your vote!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alert setTag:3];
          [alert show];
          NSMutableArray *pagesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"] mutableCopy];
          if (! pagesArray) {
               pagesArray = [[NSMutableArray alloc] init];
          } else {
               if ([pagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)3]]) {
                    [pagesArray removeObject:[NSString stringWithFormat:@"%lu", (long)3]];
                    [[NSUserDefaults standardUserDefaults] setObject:pagesArray forKey:@"visitedPagesArray"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
               }
          }
     }
     if (application.applicationState == UIApplicationStateInactive) {
               // The application was just brought from the background to the foreground,
               // so we consider the app as having been "opened by a push notification."
          [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
     }
}

- (void)getAlertForIDMethodWithCompletion:(void (^)(NSMutableArray *array, NSError *error))completion forID:(NSString *)IDString {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [AlertStructure query];
     [query whereKey:@"alertID" equalTo:IDString];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          [array addObject:object];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(array, overallError);
     });
}

- (void)getNewsForIDMethodWithCompletion:(void (^)(NSMutableArray *array, NSError *error))completion forID:(NSString *)IDString {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"articleID" equalTo:IDString];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          [array addObject:object];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(array, overallError);
     });
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
     PFInstallation *currentInstallation = [PFInstallation currentInstallation];
     if (currentInstallation.badge != 0) {
          currentInstallation.badge = 0;
     }
     NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
     [currentInstallation setValue:versionString forKey:@"version"];
     [currentInstallation saveInBackground];
}

- (void)applicationWillResignActive:(UIApplication *)application {
     
}

- (void)applicationWillTerminate:(UIApplication *)application {
     [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
     [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"visitedPagesArray"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
