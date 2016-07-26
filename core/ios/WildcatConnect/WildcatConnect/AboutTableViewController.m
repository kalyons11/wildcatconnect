//
//  AboutTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/5/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "AboutTableViewController.h"
#import <Parse/Parse.h>
#import "CapstoneViewController.h"

@interface AboutTableViewController ()

@end

@implementation AboutTableViewController {
     UIActivityIndicatorView *activity;
     BOOL reloading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
     reloading = true;
     
     self.cellHeight = 50;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     
     self.navigationController.navigationItem.title = @"About";
     
     self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     [self getConfigListWithCompletion:^(NSMutableArray *returnArray, NSError *error) {
          if (error) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
               });
          } else {
               self.developerArray = returnArray;
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
               });
          }
     }];
}

- (instancetype)init {
     [super init];
     self.navigationItem.title = @"About";
     return self;
}

- (void)getConfigListWithCompletion:(void (^)(NSMutableArray *returnArray, NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSMutableArray *string;
     [PFConfig getConfigInBackgroundWithBlock:^(PFConfig * _Nullable config, NSError * _Nullable error) {
          theError = error;
          string = config[@"developerList"];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(string, overallError);
     });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     if (indexPath.section == 3) {
          if (indexPath.row == 0) {
               return self.cellHeight;
          }
          else return 50;
     }
     else return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     if (indexPath.section == 3) {
               //List out developers...
          if (self.developerArray) {
               cell.textLabel.numberOfLines = self.developerArray.count + 3;
               self.cellHeight = (self.developerArray.count + 2) * 30;
               if (reloading) {
                    reloading = false;
                    [self.tableView reloadData];
               }
               NSString *developerString = @"Application Team\n";
               for (NSString *string in self.developerArray) {
                    developerString = [[developerString stringByAppendingString:@"\n"] stringByAppendingString:string];
               }
               cell.textLabel.text = developerString;
          } else {
               cell.textLabel.text = @"No list available.";
          }
          return cell;
     } else if (indexPath.section == 0) {
               //Version
          cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
          cell.textLabel.text = @"Version";
          cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
     } else if (indexPath.section == 1) {
               //Capstone
          cell.textLabel.text = @"Capstone Information";
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     } else if (indexPath.section == 2) {
               //Disclaimer
          cell.textLabel.text = @"Disclaimer";
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     }
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
          //Change logic here for new options...
     if (indexPath.section == 2) {
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wildcatconnect.org/a/disclaimer"]];
          [tableView deselectRowAtIndexPath:indexPath animated:YES];
     } else if (indexPath.section == 1) {
          CapstoneViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CapstoneView"];
          [self.navigationController pushViewController:controller animated:YES];
     }
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
