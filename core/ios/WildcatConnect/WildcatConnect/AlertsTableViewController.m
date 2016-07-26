//
//  AlertsTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/8/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "AlertsTableViewController.h"
#import "AlertDetailViewController.h"

@interface AlertsTableViewController ()

@end

@implementation AlertsTableViewController {
     UIActivityIndicatorView *activity;
     BOOL isReloading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
     isReloading = false;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     
     self.navigationController.navigationItem.title = @"Alerts";
     
     UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logoSmall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:nil action:nil];
     bar.enabled = false;
     self.navigationItem.leftBarButtonItem = bar;
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];
     [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
     refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"PULL TO REFRESH"];
     self.refreshControl= refreshControl;
     
     if (self.loadNumber == [NSNumber numberWithInt:1] || ! self.loadNumber) {
          [self refreshData];
     }
     else {
          activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          [barButtonItem release];
          [self getOldDataWithCompletion:^(NSMutableArray *returnArray) {
               self.alerts = returnArray;
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                    [self refreshControl];
               });
          }];
     }
}

- (void)readAllMethod {
     NSMutableArray *readArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"] mutableCopy];
     if (! readArray) {
          readArray = [[NSMutableArray alloc] init];
     }
     for (AlertStructure *NA in self.alerts) {
          if (! [readArray containsObject:NA.alertID]) {
               [readArray addObject:[NSNumber numberWithInteger:[NA.alertID integerValue]]];
          }
     }
     [[NSUserDefaults standardUserDefaults] setObject:readArray forKey:@"readAlerts"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     self.readAlerts = readArray;
     [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
     if (self.alerts.count > 0) {
          NSMutableArray *itemsToSave = [NSMutableArray array];
          for (AlertStructure *a in self.alerts) {
               [itemsToSave addObject:@{ @"titleString" : a.titleString,
                                         
                                         @"authorString" : a.authorString,
                                         
                                         @"contentString" : a.contentString,
                                         
                                         @"alertID" : a.alertID,
                                         
                                         @"hasTime" : a.hasTime,
                                         
                                         @"dateString" : a.dateString,
                                         
                                         @"isReady" : a.isReady,
                                         
                                         @"views" : a.views
                                         
                                         }];
          }
          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
          [userDefaults setObject:itemsToSave forKey:@"alertStructures"];
     }
}

- (void)getOldDataWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     AlertStructure *alertStructure;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"alertStructures"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i ++) {
          object = theArrayToSearch[i];
          alertStructure = [[AlertStructure alloc] init];
          alertStructure.alertID = [object objectForKey:@"alertID"];
          alertStructure.authorString = [object objectForKey:@"authorString"];
          alertStructure.contentString = [object objectForKey:@"contentString"];
          alertStructure.titleString = [object objectForKey:@"titleString"];
          alertStructure.hasTime = [object objectForKey:@"hasTime"];
          alertStructure.dateString = [object objectForKey:@"dateString"];
          alertStructure.isReady = [object objectForKey:@"isReady"];
          alertStructure.views = [object objectForKey:@"views"];
          [array addObject:alertStructure];
          if (i == theArrayToSearch.count - 1)
               dispatch_group_leave(serviceGroup);
     }
     if (theArrayToSearch.count == 0) {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(array);
     });
}

-(void)refreshView:(UIRefreshControl *)refresh {
     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
     
     [self refreshData];
     
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"MMMM dd, h:mm a"];
     NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                              [formatter stringFromDate:[NSDate date]]];
     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
     [refresh endRefreshing];
}

- (void)refreshData {
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     [barButtonItem release];
     [self testMethodWithCompletion:^(NSError *error, NSMutableArray *returnArrayA) {
          if (error) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
                    [self refreshControl];
               });
          } else {
               self.alerts = returnArrayA;
               [self.tableView reloadData];
               [self removeOldArrayObjectsWithCompletion:^(NSUInteger integer) {
                    NSMutableArray *itemsToSave = [NSMutableArray array];
                    for (AlertStructure *a in returnArrayA) {
                         [itemsToSave addObject:@{ @"titleString" : a.titleString,
                                                   
                                                   @"authorString" : a.authorString,
                                                   
                                                   @"contentString" : a.contentString,
                                                   
                                                   @"alertID" : a.alertID,
                                                   
                                                   @"hasTime" : a.hasTime,
                                                   
                                                   @"dateString" : a.dateString,
                                                   
                                                   @"isReady" : a.isReady,
                                                   
                                                   @"views" : a.views
                                                   
                                                   }];
                    }
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:itemsToSave forKey:@"alertStructures"];
                    NSMutableArray *readArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"];
                    if (! readArray) {
                         self.readAlerts = [NSMutableArray array];
                    } else
                         self.readAlerts = [readArray mutableCopy];
                    [userDefaults synchronize];
                    [self getCountFourMethodWithCompletion:^(NSInteger count4) {
                         dispatch_async(dispatch_get_main_queue(), ^ {
                              [activity stopAnimating];
                              UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Read All" style:UIBarButtonItemStylePlain target:self action:@selector(readAllMethod)];
                              self.navigationItem.rightBarButtonItem = barButtonItem;
                              [barButtonItem release];
                              NSMutableArray *alertsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"];
                              NSInteger read = alertsArray.count;
                              NSNumber *readNumber = [NSNumber numberWithInt:(count4 - read)];
                              if ([readNumber integerValue] > 0) {
                                   [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = [readNumber stringValue];
                              } else {
                                   [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = nil;
                              }
                         });
                    }];
               } withArray:returnArrayA];
          }
     }];
}

- (void)testMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
          //Define errors to be processed when everything is complete.
          //One error per service; in this example we'll have two
     __block NSError *firstError = nil;
          //Create the dispatch group
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     NSMutableArray *returnArray = [[NSMutableArray alloc] init];
     PFQuery *query = [AlertStructure query];
     [query orderByDescending:@"alertID"];
     [query whereKey:@"isReady" equalTo:[NSNumber numberWithInt:1]];
     query.limit = 50;
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          [returnArray addObjectsFromArray:objects];
          firstError = error;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          NSError *overallError = nil;
          if (firstError)
               overallError = firstError;
          completion(overallError, returnArray);
     });
}


- (void)removeOldArrayObjectsWithCompletion:(void (^)(NSUInteger integer))completion withArray:(NSMutableArray *)array {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     NSMutableArray *theArray = [array mutableCopy];
     NSMutableArray *dictionaryArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"];
     NSMutableArray *searchDictionaryArray = [dictionaryArray mutableCopy];
     
     NSMutableArray *currentArray = [NSMutableArray array];
     
     for (AlertStructure *NA in theArray) {
          [currentArray addObject:NA.alertID];
     }
     
     NSMutableArray *twoArray = [searchDictionaryArray mutableCopy];
     
     for (NSNumber *number in searchDictionaryArray) {
          if (! [currentArray containsObject:number]) {
               [twoArray removeObject:number];
          }
     }
     
     [[NSUserDefaults standardUserDefaults] setObject:twoArray forKey:@"readAlerts"];
     
     [[NSUserDefaults standardUserDefaults] synchronize];
     
     dispatch_group_leave(serviceGroup);
     
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(0);
     });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber {
     [super init];
     self.loadNumber = theLoadNumber;
     self.navigationItem.title = @"Alerts";
     return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (self.alerts.count == 0) {
          return 1;
     } else return self.alerts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     if (self.alerts.count == 0) {
          cell.textLabel.text = @"Loading your data...";
     } else {
          AlertStructure *alertStructure = (AlertStructure *)[self.alerts objectAtIndex:indexPath.row];
          cell.textLabel.text = alertStructure.titleString;
          cell.detailTextLabel.text = alertStructure.authorString;
          cell.textLabel.numberOfLines = 0;
          cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
                    //Show the views...
               cell.detailTextLabel.text = [[[alertStructure.authorString stringByAppendingString:@" - "] stringByAppendingString:[alertStructure.views stringValue]] stringByAppendingString:@" VIEWS"];
          }
          if (! [self.readAlerts containsObject:alertStructure.alertID]) {
               UIButton *unreadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [unreadButton setImage:[UIImage imageNamed:@"unread@2x.png"] forState:UIControlStateNormal];
               [unreadButton setEnabled:NO];
               [unreadButton sizeToFit];
               cell.accessoryView = unreadButton;
               [cell setNeedsLayout];
          }
     }
     return  cell;
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     NSString *loadString = [[NSUserDefaults standardUserDefaults] objectForKey:@"reloadAlertsPage"];
     if (! loadString || [loadString isEqualToString:@"1"]) {
          [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"reloadAlertsPage"];
          [[NSUserDefaults standardUserDefaults] synchronize];
          [self refreshData];
     }
     else {
          if (! isReloading || isReloading == false) {
               [self getOldDataWithCompletion:^(NSMutableArray *returnArray) {
                    self.alerts = returnArray;
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [self.tableView reloadData];
                         [self refreshControl];
                    });
               }];
          }
     }
     NSMutableArray *readArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"];
     if (! readArray) {
          self.readAlerts = [NSMutableArray array];
     } else
          self.readAlerts = [readArray mutableCopy];
     [self.tableView reloadData];
     [self getCountFourMethodWithCompletion:^(NSInteger count4) {
          dispatch_async(dispatch_get_main_queue(), ^ {
               NSMutableArray *alertsArray = self.readAlerts;
               NSInteger read = alertsArray.count;
               NSNumber *readNumber = [NSNumber numberWithInt:(count4 - read)];
               if ([readNumber integerValue] > 0) {
                    [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = [readNumber stringValue];
               } else {
                    [[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem].badgeValue = nil;
               }
          });
     }];
}

- (void)getCountFourMethodWithCompletion:(void (^)(NSInteger count))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     PFQuery *query = [AlertStructure query];
     __block int count;
     [query whereKey:@"isReady" equalTo:[NSNumber numberWithInt:1]];
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          count = number;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(count);
     });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     if (self.alerts.count > 0) {
          self.selectedAlertStructure = self.alerts[indexPath.row];
          AlertDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"AlertDetail"];
          controller.alert = self.selectedAlertStructure;
          [self.navigationController pushViewController:controller animated:YES];
          NSMutableArray *theReadAlerts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readAlerts"] mutableCopy];
          if (! theReadAlerts) {
               theReadAlerts = [[NSMutableArray alloc] init];
          }
          if (! [theReadAlerts containsObject:self.selectedAlertStructure.alertID]) {
               [theReadAlerts addObject:self.selectedAlertStructure.alertID];
               [[NSUserDefaults standardUserDefaults] setObject:theReadAlerts forKey:@"readAlerts"];
               self.readAlerts = theReadAlerts;
               [[NSUserDefaults standardUserDefaults] synchronize];
          }
     }
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)replaceAlertStructure:(AlertStructure *)alertStructure {
     NSNumber *index = alertStructure.alertID;
     AlertStructure *structure;
     for (int i = 0; i < self.alerts.count; i++) {
          structure = (AlertStructure *)self.alerts[i];
          if (structure.alertID == index) {
               self.alerts[i] = alertStructure;
          }
     }
     isReloading = true;
     [self.tableView reloadData];
}

@end
