//
//  SectionsTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/12/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "SectionsTableViewController.h"
#import "NewsCenterTableViewController.h"
#import "StaffDirectoryMainTableViewController.h"
#import "CommunityServiceTableViewController.h"
#import "ExtracurricularsTableViewController.h"
#import "StudentCenterTableViewController.h"
#import "UsefulLinksTableViewController.h"
#import "LunchMenusViewController.h"
#import "AdministrationLogInViewController.h"
#import "AdministrationMainTableViewController.h"
#import <Parse/Parse.h>
#import "NewsArticleStructure.h"
#import "ExtracurricularUpdateStructure.h"
#import "CommunityServiceStructure.h"
#import "PollStructure.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "EventsTableViewController.h"
#import "ScholarshipTableViewController.h"

@interface SectionsTableViewController ()

@end

@implementation SectionsTableViewController {
     UIActivityIndicatorView *activity;
     NSNumber *opps;
     NSNumber *polls;
     BOOL connected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
     
     [Utils setNavColorForController:self];
     
     self.navigationController.navigationItem.title = @"Sections";
     
     UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logoSmall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:nil action:nil];
     bar.enabled = false;
     self.navigationItem.leftBarButtonItem = bar;
     
     self.sectionsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"Wildcat News", @"Groups", @"Community Service", @"Events", @"Scholarships", @"Student Center", @"Useful Links", @"Staff Directory", @"Secure Login/Register", @"Submit a Picture", nil]];
     self.sectionsImagesArray = [[NSMutableArray alloc] init];
     [self.sectionsImagesArray addObject:@"news@2x.png"];
     [self.sectionsImagesArray addObject:@"EC@2x.png"];
     [self.sectionsImagesArray addObject:@"communityService@2x.png"];
     [self.sectionsImagesArray addObject:@"events@2x.png"];
     [self.sectionsImagesArray addObject:@"scholarship@2x.png"];
     [self.sectionsImagesArray addObject:@"studentCenter@2x.png"];
     [self.sectionsImagesArray addObject:@"usefulLinks@2x.png"];
     [self.sectionsImagesArray addObject:@"staffDirectory@2x.png"];
     [self.sectionsImagesArray addObject:@"admin@2x.png"];
     [self.sectionsImagesArray addObject:@"picture@2x.png"];
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     NSMutableArray *returnArray = [NSMutableArray array];
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activity];
      self.navigationItem.rightBarButtonItem = barButton;
     
     Reachability *reachability = [Reachability reachabilityForInternetConnection];
     NetworkStatus networkStatus = [reachability currentReachabilityStatus];
     connected = (networkStatus != NotReachable);
     
     if (connected == true) {
          [activity startAnimating];
          [self getCountMethodWithCompletion:^(NSInteger count, NSError *errorOne) {
               if (errorOne != nil) {
                    [activity stopAnimating];
               } else {
                    NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"];
                    NSInteger read = array.count;
                    NSNumber *number = [NSNumber numberWithInt:(count - read)];
                    [returnArray addObject:number];
                    [self getCountTwoMethodWithCompletion:^(NSInteger count2, NSError *errorTwo) {
                         if (errorTwo != nil) {
                              [activity stopAnimating];
                         } else {
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
                              [returnArray addObject:updates];
                              [self getCountFourMethodWithCompletion:^(NSInteger count4, NSError *errorFour) {
                                   if (errorFour != nil) {
                                        [activity stopAnimating];
                                   } else {
                                        opps = [NSNumber numberWithInteger:count4];
                                        NSNumber *oppsSeen = [[NSUserDefaults standardUserDefaults] objectForKey:@"CSviewed"];
                                        if (oppsSeen) {
                                             if ([oppsSeen integerValue] >= [opps integerValue]) {
                                                  opps = [NSNumber numberWithInt:0];
                                             } else {
                                                  opps = [NSNumber numberWithInteger:[opps integerValue] - [oppsSeen integerValue]];
                                             }
                                        } else {
                                             opps = [NSNumber numberWithInteger:[opps integerValue] - [oppsSeen integerValue]];
                                        }
                                        [returnArray addObject:opps];
                                   }
                                   [self getCountThreeMethodWithCompletion:^(NSInteger countHere, NSError *errorThree) {
                                        if (errorThree != nil) {
                                             [activity stopAnimating];
                                        } else {
                                             polls = [NSNumber numberWithInteger:countHere];
                                             NSNumber *pollsViewed = [[NSUserDefaults standardUserDefaults] objectForKey:@"pollsViewed"];
                                             if (pollsViewed) {
                                                  if ([pollsViewed integerValue] >= [polls integerValue]) {
                                                       polls = [NSNumber numberWithInt:0];
                                                  } else {
                                                       polls = [NSNumber numberWithInteger:[polls integerValue] - [pollsViewed integerValue]];
                                                  }
                                             } else {
                                                  polls = [NSNumber numberWithInteger:[polls integerValue] - [pollsViewed integerValue]];
                                             }
                                             [returnArray addObject:polls];
                                             self.sectionsNumbersArray = returnArray;
                                             [activity stopAnimating];
                                             [self.tableView reloadData];
                                             NSInteger final = [number integerValue] + [updates integerValue] + [opps integerValue] + [polls integerValue];
                                             if (final > 0) {
                                                  [[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = [[NSNumber numberWithInt:final] stringValue];
                                             }
                                             else
                                                  [[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = nil;
                                        }
                                   }];
                              }];
                         }
                    }];
               }
          }];
     }
}

- (void)getCountMethodWithCompletion:(void (^)(NSInteger count, NSError *errorOne))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"isApproved" equalTo:[NSNumber numberWithInteger:1]];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          theError = error;
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(count, overallError);
     });
}

- (void)getCountTwoMethodWithCompletion:(void (^)(NSInteger count, NSError *errorTwo))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *myArray = [[[PFInstallation currentInstallation] objectForKey:@"channels"] mutableCopy];
     for (int i = 0; i < myArray.count; i++) {
          if ([myArray[i] length] == 2) {
               myArray[i] = [NSNumber numberWithInteger:[((NSString *)[myArray[i] substringFromIndex:1]) integerValue]];
          }
     }
     PFQuery *query = [ExtracurricularUpdateStructure query];
     [query whereKey:@"extracurricularID" containedIn:myArray];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          theError = error;
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(count, overallError);
     });
}

- (void)getCountThreeMethodWithCompletion:(void (^)(NSInteger count, NSError *errorThree))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [PollStructure query];
     [query whereKey:@"isActive" equalTo:[NSNumber numberWithInteger:1]];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          theError = error;
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(count, overallError);
     });
}

- (void)getCountFourMethodWithCompletion:(void (^)(NSInteger count, NSError *errorFour))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [CommunityServiceStructure query];
     __block int count;
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          theError = error;
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(count, overallError);
     });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.sectionsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     cell.textLabel.text = self.sectionsArray[indexPath.row];
     cell.imageView.image = [UIImage imageNamed:self.sectionsImagesArray[indexPath.row]];
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     if (indexPath.row == 0) {
          NSNumber *number = [self.sectionsNumbersArray objectAtIndex:indexPath.row];
          NSInteger integer = [number integerValue];
          if (integer > 0) {
               UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [downloadButton setTitle:[number stringValue] forState:UIControlStateNormal];
               [downloadButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
               downloadButton.enabled = false;
               [downloadButton sizeToFit];
               [downloadButton setFrame:CGRectMake(0, 0, downloadButton.frame.size.width, downloadButton.frame.size.height)];
               cell.accessoryView = downloadButton;
          }
          else if (integer == 0) {
               cell.accessoryView = nil;
          }
     } else if (indexPath.row == 1) {
          NSNumber *number = [self.sectionsNumbersArray objectAtIndex:indexPath.row];
          NSInteger integer = [number integerValue];
          if (integer > 0) {
               UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [downloadButton setTitle:[number stringValue] forState:UIControlStateNormal];
               [downloadButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
               downloadButton.enabled = false;
               [downloadButton sizeToFit];
               [downloadButton setFrame:CGRectMake(0, 0, downloadButton.frame.size.width, downloadButton.frame.size.height)];
               cell.accessoryView = downloadButton;
          }
          else if (integer == 0) {
               cell.accessoryView = nil;
          }
     } else if (indexPath.row == 2) {
          NSNumber *number = [self.sectionsNumbersArray objectAtIndex:indexPath.row];
          NSInteger integer = [number integerValue];
          if (integer > 0) {
               UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [downloadButton setTitle:[number stringValue] forState:UIControlStateNormal];
               [downloadButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
               downloadButton.enabled = false;
               [downloadButton sizeToFit];
               [downloadButton setFrame:CGRectMake(0, 0, downloadButton.frame.size.width, downloadButton.frame.size.height)];
               cell.accessoryView = downloadButton;
          }
          else if (integer == 0) {
               cell.accessoryView = nil;
          }
     } else if (indexPath.row == 5) {
          NSNumber *number = [self.sectionsNumbersArray objectAtIndex:indexPath.row - 2];
          NSInteger integer = [number integerValue];
          if (integer > 0) {
               UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [downloadButton setTitle:[number stringValue] forState:UIControlStateNormal];
               [downloadButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
               downloadButton.enabled = false;
               [downloadButton sizeToFit];
               [downloadButton setFrame:CGRectMake(0, 0, downloadButton.frame.size.width, downloadButton.frame.size.height)];
               cell.accessoryView = downloadButton;
          }
          else if (integer == 0) {
               cell.accessoryView = nil;
          }

     } else if (indexPath.row == 8) {
          if ([PFUser currentUser]) {
               NSString *firstName = [[PFUser currentUser] objectForKey:@"firstName"];
               NSString *lastName = [[PFUser currentUser] objectForKey:@"lastName"];
               NSString *typeString = [[PFUser currentUser] objectForKey:@"userType"];
               cell.detailTextLabel.text = [[[@"Logged in as " stringByAppendingString:[[firstName stringByAppendingString:@" "] stringByAppendingString:lastName]] stringByAppendingString:@" - "] stringByAppendingString:typeString];
          }
     }
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (indexPath.row == 9) {
          NSString *bodyString = @"Please type a caption for this image below...\n\n\n\nPlease attach the image you want to be featured in the WildcatConnect \"Picture of the Day\" - Please note that this image will be chosen and approved by WHS Administration before appearing in the app. Thank you!";
          NSString *URLEMail = [@"mailto:picture@wildcatconnect.com?subject=WildcatConnect POTD&body=" stringByAppendingString:bodyString];
          NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
          [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
     } else {
          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
          NSMutableArray *theVisitedPagesArray = [userDefaults objectForKey:@"visitedPagesArray"];
          NSMutableArray *visitedPagesArray = [[NSMutableArray alloc] init];
          [visitedPagesArray addObjectsFromArray:theVisitedPagesArray];
          if (! visitedPagesArray) {
               visitedPagesArray = [[NSMutableArray alloc] init];
               [visitedPagesArray addObject:[NSString stringWithFormat:@"%lu", (long)indexPath.row]];
               [userDefaults setObject:visitedPagesArray forKey:@"visitedPagesArray"];
               [userDefaults synchronize];
               if (indexPath.row == 0) {
                    NewsCenterTableViewController *controller = [[NewsCenterTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 1) {
                    ExtracurricularsTableViewController *controller = [[ExtracurricularsTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 2) {
                    CommunityServiceTableViewController *controller = [[CommunityServiceTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 3) {
                    EventsTableViewController *controller = [[EventsTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 4) {
                    ScholarshipTableViewController *controller = [[ScholarshipTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 5) {
                    StudentCenterTableViewController *controller = [[StudentCenterTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 6) {
                    UsefulLinksTableViewController *controller = [[UsefulLinksTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 7) {
                    StaffDirectoryMainTableViewController *controller = [[StaffDirectoryMainTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                    [self.navigationController pushViewController:controller animated:YES];
               }
               else if (indexPath.row == 8) {
                    if ([PFUser currentUser]) {
                         AdministrationMainTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainID"];
                         [self.navigationController pushViewController:controller animated:YES];
                    } else {
                         AdministrationLogInViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInID"];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
               }
          }
          else {
               if ([visitedPagesArray containsObject:[NSString stringWithFormat:@"%lu", (long)indexPath.row]]) {
                    if (indexPath.row == 0) {
                         NewsCenterTableViewController *controller = [[NewsCenterTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:0]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 1) {
                         ExtracurricularsTableViewController *controller = [[ExtracurricularsTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:0]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 2) {
                         CommunityServiceTableViewController *controller = [[CommunityServiceTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:0]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 3) {
                         EventsTableViewController *controller = [[EventsTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:0]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 4) {
                         ScholarshipTableViewController *controller = [[ScholarshipTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:0]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 5) {
                         StudentCenterTableViewController *controller = [[StudentCenterTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:0]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 6) {
                         UsefulLinksTableViewController *controller = [[UsefulLinksTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 7) {
                         StaffDirectoryMainTableViewController *controller = [[StaffDirectoryMainTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:0]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 8) {
                         if ([PFUser currentUser]) {
                              AdministrationMainTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainID"];
                              [self.navigationController pushViewController:controller animated:YES];
                         } else {
                              AdministrationLogInViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInID"];
                              [self.navigationController pushViewController:controller animated:YES];
                         }
                    }
               }
               else {
                    [visitedPagesArray addObject:[NSString stringWithFormat:@"%lu", (long)indexPath.row]];
                    [userDefaults setObject:visitedPagesArray forKey:@"visitedPagesArray"];
                    [userDefaults synchronize];
                    if (indexPath.row == 0) {
                         NewsCenterTableViewController *controller = [[NewsCenterTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                         [self.navigationController pushViewController:controller animated:YES];
                    } else if (indexPath.row == 1) {
                         ExtracurricularsTableViewController *controller = [[ExtracurricularsTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                         [self.navigationController pushViewController:controller animated:YES];
                    } else if (indexPath.row == 2) {
                         CommunityServiceTableViewController *controller = [[CommunityServiceTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                         [self.navigationController pushViewController:controller animated:YES];
                    } else if (indexPath.row == 3) {
                         EventsTableViewController *controller = [[EventsTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 4) {
                         ScholarshipTableViewController *controller = [[ScholarshipTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 5) {
                         StudentCenterTableViewController *controller = [[StudentCenterTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 6) {
                         UsefulLinksTableViewController *controller = [[UsefulLinksTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 7) {
                         StaffDirectoryMainTableViewController *controller = [[StaffDirectoryMainTableViewController alloc] initWithLoadNumber:[NSNumber numberWithInt:1]];
                         [self.navigationController pushViewController:controller animated:YES];
                    }
                    else if (indexPath.row == 8) {
                         if ([PFUser currentUser]) {
                              AdministrationMainTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainID"];
                              [self.navigationController pushViewController:controller animated:YES];
                         } else {
                              AdministrationLogInViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInID"];
                              [self.navigationController pushViewController:controller animated:YES];
                         }
                    }
               }
          }
     }
}

@end
