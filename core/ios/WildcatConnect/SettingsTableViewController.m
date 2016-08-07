//
//  SettingsTableViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/12/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "PushSettingsTableViewController.h"
#import "AboutTableViewController.h"
#import <Parse/Parse.h>

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
     self.navigationController.navigationItem.title = @"Settings";
     
     UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logoSmall.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:nil action:nil];
     bar.enabled = false;
     self.navigationItem.leftBarButtonItem = bar;
     
     self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     
     if (indexPath.section == 0) {
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          cell.textLabel.text = @"Push Notifications";
          cell.imageView.image = [UIImage imageNamed:@"push@2x.png"];
     } else if (indexPath.section == 1) {
          cell.textLabel.text = @"App Support";
          cell.imageView.image = [UIImage imageNamed:@"email@2x.png"];
     } else if (indexPath.section == 2) {
          cell.textLabel.text = @"Feedback/Join the Team";
          cell.imageView.image = [UIImage imageNamed:@"email@2x.png"];
     } else if (indexPath.section == 3) {
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          cell.textLabel.text = @"About";
          cell.imageView.image = [UIImage imageNamed:@"about@2x.png"];
     }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (indexPath.section == 0) {
               //Push settings
          PushSettingsTableViewController *controller = [[PushSettingsTableViewController alloc] init];
          [self.navigationController pushViewController:controller animated:YES];
     } else if (indexPath.section == 1) {
               //Support mail
          /*if ([MFMailComposeViewController canSendMail]) {
               MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
               [composeViewController setMailComposeDelegate:self];
               [composeViewController setToRecipients:@[@"support@wildcatconnect.org"]];
               [composeViewController setSubject:@"WildcatConnect App Support"];
               NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
               NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
               NSString *deviceToken = [[PFInstallation currentInstallation] deviceToken];
               if (! deviceToken) {
                    deviceToken = @"Not available.";
               }
               NSString *bodyString = [[[[@"Please do not edit the folowing information.\n\nVersion = " stringByAppendingString:majorVersion] stringByAppendingString:@"\n\nDeviceToken = "] stringByAppendingString:deviceToken] stringByAppendingString:@"\n\nPlease describe your app issue below.\n\n"];
               
               [composeViewController setMessageBody:bodyString isHTML:NO];
               
               [self presentViewController:composeViewController animated:YES completion:nil];
          } else {
               NSString *URLEMail = @"mailto:support@wildcatconnect.org?subject=WildcatConnect App Support?body=Test Body";
               NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
               [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
          }*/
          
          NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
          NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
          NSString *deviceToken = [[PFInstallation currentInstallation] deviceToken];
          if (! deviceToken) {
               deviceToken = @"Not available.";
          }
          NSString *bodyString = [[[[@"Please do not edit the following information.\n\nVersion = " stringByAppendingString:majorVersion] stringByAppendingString:@"\n\nDeviceToken = "] stringByAppendingString:deviceToken] stringByAppendingString:@"\n\nPlease describe your app issue below. Include as much detail as possible for what you were doing in the application, etc.\n\n"];
          
          NSString *URLEMail = [@"mailto:support@wildcatconnect.org?subject=WildcatConnect App Support&body=" stringByAppendingString:bodyString];
          NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
          [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
     } else if (indexPath.section == 2) {
               //Team mail
          NSString *URLEMail = @"mailto:team@wildcatconnect.org";
          NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
          [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
     } else if (indexPath.section == 3) {
               //About
          AboutTableViewController *controller = [[AboutTableViewController alloc] init];
          [self.navigationController pushViewController:controller animated:YES];
     }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
     [self dismissViewControllerAnimated:YES completion:nil];
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
