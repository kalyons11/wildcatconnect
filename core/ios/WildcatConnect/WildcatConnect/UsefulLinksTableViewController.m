//
//  UsefulLinksTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 9/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "UsefulLinksTableViewController.h"
#import "UsefulLinkArray.h"

@interface UsefulLinksTableViewController ()

@end

@implementation UsefulLinksTableViewController {
     UIWebView *webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
          //Load the linksDictionary...
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     [self loadLinksWithCompletion:^(NSError *error, NSMutableArray *returnArray) {
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
               self.linksArray = returnArray;
               [self.tableView reloadData];
          }
     }];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
     self = [super initWithStyle:style];
     self.navigationItem.title = @"Useful Links";
     return self;
}

- (void)loadLinksWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [UsefulLinkArray query];
     [query orderByAscending:@"index"];
     __block NSMutableDictionary *dictionary;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          theError = error;
          for (UsefulLinkArray *object in objects) {
               dictionary = [[NSMutableDictionary alloc] init];
               [dictionary setObject:object.headerTitle forKey:@"headerTitle"];
               [dictionary setObject:object.linksArray forKey:@"linksArray"];
               [array addObject:dictionary];
          }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return self.linksArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
     return [[[self.linksArray objectAtIndex:section] objectForKey:@"linksArray"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     
     cell.textLabel.text = [[((NSMutableArray *)([[self.linksArray objectAtIndex:indexPath.section] objectForKey:@"linksArray"])) objectAtIndex:indexPath.row] objectForKey:@"titleString"];
     
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSString *URLString = [[((NSMutableArray *)([[self.linksArray objectAtIndex:indexPath.section] objectForKey:@"linksArray"])) objectAtIndex:indexPath.row] objectForKey:@"URLString"];
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
     return [[self.linksArray objectAtIndex:section] objectForKey:@"headerTitle"];
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
