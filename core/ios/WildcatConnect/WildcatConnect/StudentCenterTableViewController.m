//
//  StudentCenterTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/3/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "StudentCenterTableViewController.h"
#import <Parse/Parse.h>
#import "PollStructure.h"
#import "PollDetailViewController.h"

@interface StudentCenterTableViewController ()

@end

@implementation StudentCenterTableViewController {
     UIActivityIndicatorView *activity;
     BOOL reload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
     reload = true;
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];
     [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
     refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"PULL TO REFRESH"];
     self.refreshControl= refreshControl;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     
     self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
     
     [self refreshData];
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

- (void)refreshData {
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     [self getNewPollsMethodWithCompletion:^(NSError *error, NSMutableArray *returnArray) {
          if (error) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    reload = false;
                    [self.tableView reloadData];
                    [self refreshControl];
                    [self.refreshControl endRefreshing];
               });
          } else {
               self.pollArray = returnArray;
               NSMutableArray *itemsToSave = [NSMutableArray array];
               for (PollStructure *p in returnArray) {
                    [itemsToSave addObject:@{ @"pollTitle" : p.pollTitle, @"pollQuestion" : p.pollQuestion, @"pollMultipleChoices" : p.pollMultipleChoices, @"pollID" : p.pollID, @"totalResponses" : p.totalResponses, @"objectId" : p.objectId , @"daysActive" : p.daysActive }];
               }
               [[NSUserDefaults standardUserDefaults] setObject:itemsToSave forKey:@"pollStructures"];
               [[NSUserDefaults standardUserDefaults] synchronize];
               [self removeOldArrayObjectsWithCompletion:^(NSUInteger integer) {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [activity stopAnimating];
                         reload = false;
                         [self.tableView reloadData];
                         [self refreshControl];
                         [self.refreshControl endRefreshing];
                    });
               } withArray:returnArray];
          }
     }];
}

- (void)viewDidDisappear:(BOOL)animated {
     [super viewDidDisappear:animated];
     NSMutableArray *itemsToSave = [NSMutableArray array];
     for (PollStructure *p in self.pollArray) {
          [itemsToSave addObject:@{ @"pollTitle" : p.pollTitle, @"pollQuestion" : p.pollQuestion, @"pollMultipleChoices" : p.pollMultipleChoices, @"pollID" : p.pollID, @"totalResponses" : p.totalResponses, @"objectId" : p.objectId , @"daysActive" : p.daysActive}];
     }
     [[NSUserDefaults standardUserDefaults] setObject:itemsToSave forKey:@"pollStructures"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeOldArrayObjectsWithCompletion:(void (^)(NSUInteger integer))completion withArray:(NSMutableArray *)array {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     NSMutableArray *theArray = [array mutableCopy];
     NSMutableArray *dictionaryArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"answeredPolls"];
     NSMutableArray *searchDictionaryArray = [dictionaryArray mutableCopy];
               //Have some objects to remove...
     NSMutableArray *currentArray = [NSMutableArray array];
     
     for (PollStructure *poll in theArray) {
          [currentArray addObject:poll.pollID];
     }
     
     NSMutableArray *twoArray = [searchDictionaryArray mutableCopy];
     
     for (NSNumber *number in searchDictionaryArray) {
          if (! [currentArray containsObject:number]) {
               [twoArray removeObject:number];
          }
     }
     
     [[NSUserDefaults standardUserDefaults] setObject:twoArray forKey:@"answeredPolls"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     dispatch_group_leave(serviceGroup);
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(0);
     });
}

- (void)getOldPollsMethodWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     PollStructure *pollStructure;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"pollStructures"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i++) {
          object = theArrayToSearch[i];
          pollStructure = [[PollStructure alloc] init];
          pollStructure.pollTitle = [object objectForKey:@"pollTitle"];
          pollStructure.pollQuestion = [object objectForKey:@"pollQuestion"];
          pollStructure.pollMultipleChoices = [object objectForKey:@"pollMultipleChoices"];
          pollStructure.pollID = [object objectForKey:@"pollID"];
          pollStructure.totalResponses = [object objectForKey:@"totalResponses"];
          pollStructure.objectId = [object objectForKey:@"objectId"];
          pollStructure.daysActive = [object objectForKey:@"daysActive"];
          [array addObject:pollStructure];
          if (i == theArrayToSearch.count - 1) {
               dispatch_group_leave(serviceGroup);
          }
     }
     if (theArrayToSearch.count == 0) {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(array);
     });
}

- (void)getNewPollsMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
     __block NSError *firstError = nil;
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     NSMutableArray *returnArray = [[NSMutableArray alloc] init];
     PFQuery *query = [PollStructure query];
     [query orderByDescending:@"pollID"];
     [query whereKey:@"isActive" equalTo:[NSNumber numberWithInteger:1]];
     query.limit = 10;
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          [returnArray addObjectsFromArray:objects];
          firstError = error;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          NSError *overallError = nil;
          if (firstError) {
               overallError = firstError;
          }
          completion(overallError, returnArray);
     });
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber {
     self = [super init];
     self.loadNumber = theLoadNumber;
     self.navigationItem.title = @"Student Center";
     return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (self.pollArray.count == 0) {
          return 1;
     } else return self.pollArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
    
     if (self.pollArray.count == 0 && reload == true) {
          cell.textLabel.text = @"Loading your data...";
     } else if (self.pollArray.count == 0 && reload == false) {
          cell.textLabel.text = @"No polls to display.";
     } else {
          PollStructure *pollStructure = (PollStructure *)[self.pollArray objectAtIndex:indexPath.row];
          cell.textLabel.text = pollStructure.pollTitle;
          cell.textLabel.numberOfLines = 0;
          cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          if (! [self.answeredPolls containsObject:pollStructure.pollID]) {
               UIButton *unreadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [unreadButton setImage:[UIImage imageNamed:@"unread@2x.png"] forState:UIControlStateNormal];
               [unreadButton setEnabled:NO];
               [unreadButton sizeToFit];
               cell.accessoryView = unreadButton;
               [cell setNeedsLayout];
          }
     }
    
    return cell;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
     
}

- (void)viewWillDisappear:(BOOL)animated {
     [super viewWillDisappear:animated];
     NSNumber *count = [NSNumber numberWithInteger:self.pollArray.count];
     [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"pollsViewed"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     NSMutableArray *readArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"answeredPolls"];
     if (! readArray) {
          self.answeredPolls = [NSMutableArray array];
     } else
          self.answeredPolls = [readArray mutableCopy];
     [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (self.pollArray.count > 0) {
          self.selectedPollStructure = self.pollArray[indexPath.row];
          PollDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PollDetail"];
          controller.pollStructure = self.selectedPollStructure;
          [self.navigationController pushViewController:controller animated:YES];
     }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     return @"CURRENT POLLS";
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
