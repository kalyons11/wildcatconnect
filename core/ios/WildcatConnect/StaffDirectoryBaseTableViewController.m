//
//  StaffDirectoryBaseTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/14/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "StaffDirectoryBaseTableViewController.h"
#import "StaffMemberStructure.h"
#import "EmailButton.h"

NSString *const kCellIdentifier = @"cellID";
NSString *const kTableCellNibName = @"TableCell";

@interface StaffDirectoryBaseTableViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation StaffDirectoryBaseTableViewController

- (void)viewDidLoad {
     [super viewDidLoad];
     [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
     CGFloat bottom =  self.tabBarController.tabBar.frame.size.height;
     [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, bottom, 0)];
     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
     self.extendedLayoutIncludesOpaqueBars = YES;
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell forStaffMemberStructure:(StaffMemberStructure *)staffMemberStructure {
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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) buttonTouchUpInside:(id)sender {
     EmailButton *buttonClicked = (EmailButton *)sender;
     NSString *mail = buttonClicked.staffMember.staffMemberEMail;
     NSString *URLEMail = [@"mailto:" stringByAppendingString:mail];
     NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
     [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
}

+ (NSString*) kCellIdentifierString {
     return kCellIdentifier;
}

@end
