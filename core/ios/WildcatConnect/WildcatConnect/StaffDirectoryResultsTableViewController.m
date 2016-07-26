//
//  StaffDirectoryResultsTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/14/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "StaffDirectoryResultsTableViewController.h"
#import "StaffMemberStructure.h"
#import "EmailButton.h"

@interface StaffDirectoryResultsTableViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation StaffDirectoryResultsTableViewController

@synthesize filteredStaffMembers;

- (void)viewDidLoad {
     
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (self.filteredStaffMembers.count == 0)
          return 1;
     return self.filteredStaffMembers.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
     return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
          // Return the number of sections.
     return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     if (self.filteredStaffMembers.count == 0) {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:@"cellID"];
          cell.textLabel.text = @"No results.";
          return cell;
     }
     else {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:@"cellID"];
          StaffMemberStructure *staffMemberStructure = self.filteredStaffMembers[indexPath.row];
          cell.textLabel.text = [staffMemberStructure fullNameCommaString];
          NSString *string = staffMemberStructure.staffMemberTitle;
          cell.detailTextLabel.text = [[string stringByAppendingString:@" - "] stringByAppendingString: staffMemberStructure.staffMemberLocation];
          cell.detailTextLabel.numberOfLines = 0;
          cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
          EmailButton *emailButton = [EmailButton buttonWithType:UIButtonTypeRoundedRect];
          [emailButton setImage:[UIImage imageNamed:@"email@2x.png"] forState:UIControlStateNormal];
          [emailButton setEnabled:YES];
          [emailButton sizeToFit];
          emailButton.staffMember = staffMemberStructure;
          [emailButton addTarget:self
                          action:@selector(buttonTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
          [emailButton setFrame:CGRectMake(0, 0, emailButton.frame.size.width, emailButton.frame.size.height)];
          cell.accessoryView = emailButton;
          [cell setNeedsLayout];
          return cell;
     }
}

- (IBAction) buttonTouchUpInside:(id)sender {
     EmailButton *buttonClicked = (EmailButton *)sender;
     NSString *mail = buttonClicked.staffMember.staffMemberEMail;
     NSString *URLEMail = [@"mailto:" stringByAppendingString:mail];
     NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
     [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
     [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
