//
//  ScholarshipTableViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 3/7/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "ScholarshipTableViewController.h"
#import "ScholarshipStructure.h"
#import "ScholarshipDetailViewController.h"

@interface ScholarshipTableViewController ()

@end

@implementation ScholarshipTableViewController {
     UIActivityIndicatorView *activity;
     BOOL reload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
     reload = true;
    
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
          [self getPreviousCommunityServiceStructuresWithCompletion:^(NSMutableArray *returnArray) {
               self.scholarships = returnArray;
               dispatch_async(dispatch_get_main_queue(), ^ {
                    reload = false;
                    [self.tableView reloadData];
                    [self refreshControl];
               });
          }];
     }
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber {
     self = [super init];
     self.loadNumber = theLoadNumber;
     self.navigationItem.title = @"Scholarships";
     return self;
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
                    reload = false;
                    [self.tableView reloadData];
                    [self refreshControl];
                    [self.refreshControl endRefreshing];
               });
          } else {
               self.scholarships = returnArrayA;
               NSMutableArray *itemsToSave = [NSMutableArray array];
               for (ScholarshipStructure *c in returnArrayA) {
                    [itemsToSave addObject:@{ @"titleString"     : c.titleString, @"dueDate" : c.dueDate, @"messageString"  : c.messageString
                                              }];
               }
               NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
               [userDefaults setObject:itemsToSave forKey:@"scholarshipItems"];
               [userDefaults synchronize];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    reload = false;
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
               });
          }
     }];
}

- (void)getPreviousCommunityServiceStructuresWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     ScholarshipStructure *CSStructure;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"scholarshipItems"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i++) {
          object = theArrayToSearch[i];
          CSStructure = [[ScholarshipStructure alloc] init];
          CSStructure.titleString = [object objectForKey:@"titleString"];
          CSStructure.dueDate = [object objectForKey:@"dueDate"];
          CSStructure.messageString = [object objectForKey:@"messageString"];
          [array addObject:CSStructure];
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

- (void)testMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
          //Define errors to be processed when everything is complete.
          //One error per service; in this example we'll have two
     __block NSError *firstError = nil;
          //Create the dispatch group
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     NSMutableArray *returnArray = [[NSMutableArray alloc] init];
     PFQuery *query = [ScholarshipStructure query];
     [query orderByAscending:@"dueDate"];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
          // Configure the cell...
     if (self.scholarships.count == 0 && reload == true) {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
          cell.textLabel.text = @"Loading your data...";
          return  cell;
     } else if (self.scholarships.count == 0 && reload == false) {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
          cell.textLabel.text = @"No scholarships to display.";
          return  cell;
     } else {
          ScholarshipStructure *structure = ((ScholarshipStructure *)[self.scholarships objectAtIndex:indexPath.row]);
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
          cell.textLabel.text = structure.titleString;
          cell.textLabel.numberOfLines = 0;
          cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
          NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
          [formatter setDateFormat:@"MMMM d"];
          cell.detailTextLabel.text = [@"DUE - " stringByAppendingString:[formatter stringFromDate:structure.dueDate]];
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          return cell;
     }
     return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (self.scholarships.count > 0) {
          ScholarshipDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ScholDetail"];
          ScholarshipStructure *S = ((ScholarshipStructure *)[self.scholarships objectAtIndex:indexPath.row]);
          controller.scholarship = S;
          [self.navigationController pushViewController:controller animated:YES];
     }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 90;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
          // Return the number of rows in the section.
     if (self.scholarships.count == 0)
          return 1;
     else
          return self.scholarships.count;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
