//
//  EventsTableViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/16/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "EventsTableViewController.h"
#import "EventStructure.h"
#import <Parse/Parse.h>
#import "EventDetailViewController.h"

@interface EventsTableViewController ()

@end

@implementation EventsTableViewController {
     UIActivityIndicatorView *activity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     
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
     } else {
          [self getPreviousEventsMethodWithCompletion:^(NSMutableArray *returnArray) {
               self.allEvents = returnArray;
               NSMutableArray *copyArray = [self.allEvents mutableCopy];
               self.todayEvents = [[NSMutableArray alloc] init];
               self.upcomingEvents = [[NSMutableArray alloc] init];
               for (EventStructure *event in self.allEvents) {
                    if ([self daysBetweenDate:event.eventDate andDate:[NSDate date]] == 0) {
                         [self.todayEvents addObject:event];
                         [copyArray removeObject:event];
                    } else if ([self daysBetweenDate:[NSDate date] andDate:event.eventDate] < 10) {
                         [self.upcomingEvents addObject:event];
                         [copyArray removeObject:event];
                    }
               }
               self.allEvents = copyArray;
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [self.tableView reloadData];
                    [self refreshControl];
               });
          }];
     }
}

- (void)getPreviousEventsMethodWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     EventStructure *event;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"eventItems"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i++) {
          object = theArrayToSearch[i];
          event = [[EventStructure alloc] init];
          event.titleString = [object objectForKey:@"titleString"];
          event.locationString = [object objectForKey:@"locationString"];
          event.eventDate = [object objectForKey:@"eventDate"];
          event.messageString = [object objectForKey:@"messageString"];
          [array addObject:event];
          if (i == theArrayToSearch.count - 1)
               dispatch_group_leave(serviceGroup);
     }
     if (theArrayToSearch.count == 0) {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(array);
     });
}

- (void)refreshData {
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     [self testMethodWithCompletion:^(NSError *error, NSMutableArray *returnArrayA) {
          if (error) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
                    [self refreshControl];
                    [self.refreshControl endRefreshing];
               });
          } else {
               self.allEvents = returnArrayA;
               NSMutableArray *itemsToSave = [NSMutableArray array];
               for (EventStructure *c in returnArrayA) {
                    [itemsToSave addObject:@{ @"titleString"     : c.titleString, @"locationString" : c.locationString, @"eventDate"  : c.eventDate, @"messageString" : c.messageString
                                              }];
               }
               NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
               [userDefaults setObject:itemsToSave forKey:@"eventItems"];
               [userDefaults synchronize];
               NSMutableArray *copyArray = [self.allEvents mutableCopy];
               self.todayEvents = [[NSMutableArray alloc] init];
               self.upcomingEvents = [[NSMutableArray alloc] init];
               for (EventStructure *event in self.allEvents) {
                    if ([self daysBetweenDate:event.eventDate andDate:[NSDate date]] == 0) {
                         [self.todayEvents addObject:event];
                         [copyArray removeObject:event];
                    } else if ([self daysBetweenDate:[NSDate date] andDate:event.eventDate] < 10) {
                         [self.upcomingEvents addObject:event];
                         [copyArray removeObject:event];
                    }
               }
               self.allEvents = copyArray;
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
               });
          }
     }];
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

- (void)testMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
          //Define errors to be processed when everything is complete.
          //One error per service; in this example we'll have two
     __block NSError *firstError = nil;
          //Create the dispatch group
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     NSMutableArray *returnArray = [[NSMutableArray alloc] init];
     PFQuery *query = [EventStructure query];
     [query whereKey:@"isApproved" equalTo:[NSNumber numberWithInteger:1]];
     [query orderByAscending:@"eventDate"];
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

-(void)refreshView:(UIRefreshControl *)refresh {
     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
     
          // custom refresh logic would be placed here...
     
     [self refreshData];
     
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"MMMM dd, h:mm a"];
     NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                              [formatter stringFromDate:[NSDate date]]];
     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
     [refresh endRefreshing];
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber {
     self = [super init];
     self.loadNumber = theLoadNumber;
     self.navigationItem.title = @"Events";
     return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (section == 0) {
          if (self.todayEvents.count == 0) {
               return 1;
          } else return self.todayEvents.count;
     } else if (section == 1) {
          if (self.upcomingEvents.count == 0) {
               return 1;
          } else return self.upcomingEvents.count;
     } else if (section == 2) {
          if (self.allEvents.count == 0) {
               return 1;
          } else return self.allEvents.count;
     } else return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     if ((indexPath.section == 0 && self.todayEvents.count == 0) || (indexPath.section == 1 && self.upcomingEvents.count == 0) || (indexPath.section == 2 && self.allEvents.count == 0)) {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
          cell.textLabel.text = @"No events here.";
          return  cell;
     } else {
          EventStructure *event;
          if (indexPath.section == 0) {
               event = ((EventStructure *)[self.todayEvents objectAtIndex:indexPath.row]);
          } else if (indexPath.section == 1) {
               event = ((EventStructure *)[self.upcomingEvents objectAtIndex:indexPath.row]);
          } else if (indexPath.section == 2) {
               event = ((EventStructure *)[self.allEvents objectAtIndex:indexPath.row]);
          }
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
          cell.textLabel.text = event.titleString;
          cell.textLabel.numberOfLines = 0;
          cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
          [dateFormatter setDateFormat:@"EEEE, MMMM d, YYYY @ h:mm a"];
          NSString *startString = [dateFormatter stringFromDate:event.eventDate];
          cell.detailTextLabel.text = [[startString stringByAppendingString:@" - "] stringByAppendingString:event.locationString];
          cell.detailTextLabel.numberOfLines = 8;
          return cell;
     }
     return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (indexPath.section == 0 && self.todayEvents.count > 0) {
          EventStructure *theEvent = [self.todayEvents objectAtIndex:indexPath.row];
          EventDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EventDetail"];
          controller.event = theEvent;
          [self.navigationController pushViewController:controller animated:YES];
     } else if (indexPath.section == 1 && self.upcomingEvents.count > 0) {
          EventStructure *theEvent = [self.upcomingEvents objectAtIndex:indexPath.row];
          EventDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EventDetail"];
          controller.event = theEvent;
          [self.navigationController pushViewController:controller animated:YES];
     } else if (indexPath.section == 2 && self.allEvents.count > 0) {
          EventStructure *theEvent = [self.allEvents objectAtIndex:indexPath.row];
          EventDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EventDetail"];
          controller.event = theEvent;
          [self.navigationController pushViewController:controller animated:YES];
     }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     if (section == 0) {
          return @"TODAY";
     } else if (section == 1) {
          return @"UPCOMING";
     } else if (section == 2) {
          return @"ALL EVENTS";
     } else return nil;
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

@end
