//
//  PushSettingsTableViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/12/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "PushSettingsTableViewController.h"
#import <Parse/Parse.h>
#import "ExtracurricularStructure.h"

@interface PushSettingsTableViewController ()

@end

@implementation PushSettingsTableViewController {
     BOOL hasChanged;
     UIActivityIndicatorView *activity;
     UIAlertView *postAlertView;
     UIAlertView *noAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
     hasChanged = false;
     
     self.navigationItem.title = @"Push Notifications";
     
     self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(goBack:)];
     
     self.navigationItem.leftBarButtonItem = bbtnBack;
     
     NSString *string = [[PFInstallation currentInstallation] objectForKey:@"deviceToken"];
     
     if (string == nil) {
          noAlertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You have not enabled push notifications for this device. Please turn on notifications in your iPhone settings, close the app and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
          [noAlertView show];
     } else {
          activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          
          [[PFInstallation currentInstallation] fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
               self.pushArray = [NSMutableArray arrayWithArray:((PFInstallation *)object).channels];
               [activity stopAnimating];
               [self.tableView reloadData];
          }];
     }
}

- (void)getChannelsMethodWithCompletion:(void (^)(NSMutableArray *returnArray, NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *returnArray = [NSMutableArray array];
     PFQuery *query = [PFInstallation query];
     [query whereKey:@"deviceToken" equalTo:[[PFInstallation currentInstallation] deviceToken]];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          [returnArray addObjectsFromArray:[[objects objectAtIndex:0] objectForKey:@"channels"]];
          if (error != nil) {
               theError = error;
          }
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil && returnArray.count == 0) {
               overallError = theError;
          }
          completion(returnArray, overallError);
     });
}

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? You have not saved your push settings."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
     else {
          [self.navigationController popViewControllerAnimated:YES];
     }
}

- (instancetype)init {
     [super init];
     self.navigationItem.title = @"Push Notifications";
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
     return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     return @"SELECT THE PUSH NOTIFICATIONS YOU WOULD LIKE TO RECEIVE...";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     
     UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
     
     if (indexPath.section == 0) {
          if (indexPath.row == 0) {
               if (self.pushArray.count > 0 && [self.pushArray containsObject:@"allNews"]) {
                    [switchView setOn:YES animated:NO];
               } else
                    [switchView setOn:NO animated:NO];
          } else if (indexPath.row == 1) {
               if (self.pushArray.count > 0 && [self.pushArray containsObject:@"allCS"]) {
                    [switchView setOn:YES animated:NO];
               } else
                    [switchView setOn:NO animated:NO];
          } else if (indexPath.row == 2) {
               if (self.pushArray.count > 0 && [self.pushArray containsObject:@"allPolls"]) {
                    [switchView setOn:YES animated:NO];
               } else
                    [switchView setOn:NO animated:NO];
          }
     }
     
     [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
     
     if (indexPath.section == 0) {
          if (indexPath.row == 0) {
               cell.textLabel.text = @"All News Articles";
               [switchView setTag:0];
          } else if (indexPath.row == 1) {
               cell.textLabel.text = @"All Community Service";
               [switchView setTag:1];
          } else if (indexPath.row == 2) {
               cell.textLabel.text = @"All Poll Questions";
               [switchView setTag:2];
          }
          cell.accessoryView = switchView;
     }
     
     [switchView release];
    
     return cell;
}

- (void)switchChanged:(id)sender {
     hasChanged = true;
     UISwitch* switchControl = sender;
     if (switchControl.tag == 0) {
          if (switchControl.on == true) {
               if (! [self.pushArray containsObject:@"allNews"]) {
                    [self.pushArray addObject:@"allNews"];
               }
          } else {
               if ([self.pushArray containsObject:@"allNews"]) {
                    [self.pushArray removeObject:@"allNews"];
               }
          }
     } else if (switchControl.tag == 1) {
          if (switchControl.on == true) {
               if (! [self.pushArray containsObject:@"allCS"]) {
                    [self.pushArray addObject:@"allCS"];
               }
          } else {
               if ([self.pushArray containsObject:@"allCS"]) {
                    [self.pushArray removeObject:@"allCS"];
               }
          }
     } else if (switchControl.tag == 2) {
          if (switchControl.on == true) {
               if (! [self.pushArray containsObject:@"allPolls"]) {
                    [self.pushArray addObject:@"allPolls"];
               }
          } else {
               if ([self.pushArray containsObject:@"allPolls"]) {
                    [self.pushArray removeObject:@"allPolls"];
               }
          }
     }
     if (self.pushArray.count > 1 || hasChanged == true) {
          hasChanged = true;
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveChannels)];
          self.navigationItem.rightBarButtonItem = barButtonItem;
     } else
          self.navigationItem.rightBarButtonItem = nil;
}

- (void)saveChannels {
     postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you save these Push Notification settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
     [postAlertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
     if (actionSheet == postAlertView) {
          if (buttonIndex == 1) {
               activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
               [activity setBackgroundColor:[UIColor clearColor]];
               [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
               UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
               self.navigationItem.rightBarButtonItem = barButtonItem;
               [activity startAnimating];
               [self saveChannelsMethodWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [activity stopAnimating];
                         [self.navigationController popViewControllerAnimated:YES];
                    });
               }];
          }
     } else if (actionSheet == noAlertView) {
          [self.navigationController popViewControllerAnimated:YES];
     } else {
          if (buttonIndex == 1) {
               [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
          }
     }
}

- (void)saveChannelsMethodWithCompletion:(void (^)(NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFInstallation *currentInstallation = [PFInstallation currentInstallation];
     if (self.pushArray.count > 0) {
          [currentInstallation setObject:self.pushArray forKey:@"channels"];
          [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               theError = error;
               dispatch_group_leave(serviceGroup);
          }];
     } else {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(theError);
     });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

@end
