//
//  LunchMenusViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/12/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "LunchMenusViewController.h"
#import "LunchMenusStructure.h"

@interface LunchMenusViewController ()

@end

@implementation LunchMenusViewController {
     BOOL reloading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
     reloading = true;
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
    // Do any additional setup after loading the view.
     UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     self.tableView.rowHeight = UITableViewAutomaticDimension;
     self.tableView.estimatedRowHeight = 40;
     
     [self getStructuresWithCompletion:^(NSError *error, NSMutableArray *returnArray) {
          if (error != nil) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
                    [self refreshControl];
                    [self.refreshControl endRefreshing];
               });
          } else {
               [activity stopAnimating];
               self.theStructuresArray = returnArray;
               [self.tableView reloadData];
          }
     }];
}

- (void)getStructuresWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [LunchMenusStructure query];
     [query orderByAscending:@"lunchStructureID"];
     query.limit = 5;
     NSMutableArray *returnArray = [NSMutableArray array];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          theError = error;
          [returnArray addObjectsFromArray:objects];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, returnArray);
     });
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
     self = [super initWithStyle:style];
     self.navigationItem.title = @"Lunch Menus";
     return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"CellIdentifier"];
    
     if (! self.theStructuresArray) {
          cell.detailTextLabel.text = @"No data to display.";
     } else {
          if (indexPath.row == 0) {
               cell.textLabel.text = @"BREAKFAST";
               cell.detailTextLabel.numberOfLines = 0;
               cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
               cell.textLabel.font = [cell.textLabel.font fontWithSize:10];
               cell.detailTextLabel.text = ( (LunchMenusStructure *) ([self.theStructuresArray objectAtIndex:indexPath.section]) ).breakfastString;
               [cell updateConstraintsIfNeeded];
          }
          if (indexPath.row == 1) {
               cell.textLabel.text = @"LUNCH";
               cell.textLabel.font = [cell.textLabel.font fontWithSize:10];
               [cell.textLabel sizeToFit];
               cell.detailTextLabel.numberOfLines = 0;
               cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
               cell.detailTextLabel.text = ( (LunchMenusStructure *) ([self.theStructuresArray objectAtIndex:indexPath.section]) ).lunchString;
               [cell updateConstraintsIfNeeded];
          }
     }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 80;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
     if ( ! self.theStructuresArray) {
         return @"No data to display.";
     } else {
          return ( (LunchMenusStructure *) ([self.theStructuresArray objectAtIndex:section]) ).dateString;
     }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
