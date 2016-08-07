//
//  AdministrationMainTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/4/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "AdministrationMainTableViewController.h"
#import <Parse/Parse.h>
#import "AdministrationLogInViewController.h"
#import "ComposeNewsArticleViewController.h"
#import "ComposeExtracurricularUpdateViewController.h"
#import "ComposeCommunityServiceViewController.h"
#import "ComposePollViewController.h"
#import "EditMessagesViewController.h"
#import "EditPictureDayViewController.h"
#import "ComposeAlertViewController.h"
#import "RegisterExtracurricularViewController.h"
#import "EditScheduleViewController.h"
#import "ComposeEventViewController.h"

@interface AdministrationMainTableViewController ()

@end

@implementation AdministrationMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutCurrentUser)];
     self.navigationItem.rightBarButtonItem = logoutButton;
     
     NSString *firstName = [[PFUser currentUser] objectForKey:@"firstName"];
     NSString *lastName = [[PFUser currentUser] objectForKey:@"lastName"];
     
     self.topBar.topItem.title = [[lastName stringByAppendingString:@", "] stringByAppendingString:firstName];
     
     self.sectionsArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"Wildcat News Story", @"Group Update", @"Event", @"Community Service Update", nil]];
     
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          [self.sectionsArray addObject:@"User Poll"];
          [self.sectionsArray addObject:@"Alert"];
     }
     
     self.sectionsImagesArray = [[NSMutableArray alloc] init];
     [self.sectionsImagesArray addObject:@"news@2x.png"];
     [self.sectionsImagesArray addObject:@"EC@2x.png"];
     [self.sectionsImagesArray addObject:@"events@2x.png"];
     [self.sectionsImagesArray addObject:@"communityService@2x.png"];
     
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          [self.sectionsImagesArray addObject:@"studentCenter@2x.png"];
          [self.sectionsImagesArray addObject:@"alerts@2x.png"];
     }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)logOutCurrentUser {
     [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
          [self.navigationController popToRootViewControllerAnimated:YES];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          return 3;
     } else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          if (section == 0) {
               return 3;
          } else if (section == 1)
               return self.sectionsArray.count - 2;
          else
               return 2; // Change password, new extracurricular group...
     } else {
          if (section == 0)
               return 4;
          else
               return 2; // Change password, new extracurricular group...
     }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          if (section == 0) {
               return @"ADMINISTRATIVE TOOLS";
          } else if (section == 1)
               return @"FACULTY TOOLS";
          else
               return @"ACCOUNT MANAGEMENT";
     } else {
          if (section == 0)
               return @"FACULTY TOOLS";
          else
               return @"ACCOUNT MANAGEMENT";
     }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
     return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          if (indexPath.section == 0) {
               if (indexPath.row == 0) {
                    cell.textLabel.text = @"Picture of the Day";
                    cell.imageView.image = [UIImage imageNamed:@"picture@2x.png"];
               } else {
                    cell.textLabel.text = self.sectionsArray[indexPath.row + 3];
                    cell.imageView.image = [UIImage imageNamed:self.sectionsImagesArray[indexPath.row + 3]];
               }
          } else if (indexPath.section == 1) {
               cell.textLabel.text = self.sectionsArray[indexPath.row];
               cell.imageView.image = [UIImage imageNamed:self.sectionsImagesArray[indexPath.row]];
          } else if (indexPath.section == 2) {
               if (indexPath.row == 0) {
                    cell.textLabel.text = @"Change Password";
                    cell.imageView.image = [UIImage imageNamed:@"password@2x.png"];
               } else if (indexPath.row == 1) {
                    cell.textLabel.text = @"Register Group";
                    cell.imageView.image = [UIImage imageNamed:@"EC@2x.png"];
               }
          }
     } else {
          if (indexPath.section == 0) {
               cell.textLabel.text = self.sectionsArray[indexPath.row];
               cell.imageView.image = [UIImage imageNamed:self.sectionsImagesArray[indexPath.row]];
          } else if (indexPath.section == 1) {
               if (indexPath.row == 0) {
                    cell.textLabel.text = @"Change Password";
                    cell.imageView.image = [UIImage imageNamed:@"password@2x.png"];
               } else if (indexPath.row == 1) {
                    cell.textLabel.text = @"Register Group";
                    cell.imageView.image = [UIImage imageNamed:@"EC@2x.png"];
               }
          }
     }
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          if (indexPath.section == 0) {
               if (indexPath.row == 0) {
                    EditPictureDayViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EditPicture"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 1) {
                    ComposePollViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ComposePoll"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 2) {
                    ComposeAlertViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ComposeAlert"];
                    [self.navigationController pushViewController:controller animated:YES];
               }
          } else if (indexPath.section == 1) {
               if (indexPath.row == 0) {
                    ComposeNewsArticleViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeNewsArticle"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 1) {
                    ComposeExtracurricularUpdateViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeExtracurricular"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 2) {
                    ComposeEventViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeEvent"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 3) {
                    ComposeCommunityServiceViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeCommunity"];
                    [self.navigationController pushViewController:controller animated:YES];
               }
          } else if (indexPath.section == 2) {
               if (indexPath.row == 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change Password?" message:[[@"Are you sure you want to reset your password? An e-mail will be sent to you at " stringByAppendingString:[[PFUser currentUser] email]] stringByAppendingString:@" with instructions."] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [alertView show];
               } else if (indexPath.row == 1) {
                    RegisterExtracurricularViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterEC"];
                    [self.navigationController pushViewController:controller animated:YES];
               }
          }
     } else {
          if (indexPath.section == 0) {
               if (indexPath.row == 0) {
                    ComposeNewsArticleViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeNewsArticle"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 1) {
                    ComposeExtracurricularUpdateViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeExtracurricular"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 2) {
                    ComposeEventViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeEvent"];
                    [self.navigationController pushViewController:controller animated:YES];
               } else if (indexPath.row == 3) {
                    ComposeCommunityServiceViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ComposeCommunity"];
                    [self.navigationController pushViewController:controller animated:YES];
               }
          } else if (indexPath.section == 1) {
               if (indexPath.row == 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change Password?" message:[[@"Are you sure you want to reset your password? An e-mail will be sent to you at " stringByAppendingString:[[PFUser currentUser] email]] stringByAppendingString:@" with instructions."] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [alertView show];
               } else if (indexPath.row == 1) {
                    RegisterExtracurricularViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterEC"];
                    [self.navigationController pushViewController:controller animated:YES];
               }
          }
     }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
     if (buttonIndex == 1) {
          UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          [PFUser requestPasswordResetForEmailInBackground:[[PFUser currentUser] email] block:^(BOOL succeeded, NSError * _Nullable error) {
               [activity stopAnimating];
               UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutCurrentUser)];
               self.navigationItem.rightBarButtonItem = logoutButton;
          }];
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
