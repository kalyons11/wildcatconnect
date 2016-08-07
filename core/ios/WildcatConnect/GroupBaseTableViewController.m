//
//  GroupBaseTableViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/21/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "GroupBaseTableViewController.h"
#import "ExtracurricularStructure.h"
#import "AddGroupButton.h"
#import "ExtracurricularsTableViewController.h"

@interface GroupBaseTableViewController ()

@end

@implementation GroupBaseTableViewController {
     UIActivityIndicatorView *activity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     
     [super viewDidLoad];
     [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
     CGFloat bottom =  self.tabBarController.tabBar.frame.size.height;
     [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, bottom, 0)];
     self.tableView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
     self.extendedLayoutIncludesOpaqueBars = YES;
}

- (UITableViewCell *)configureCell:(UITableViewCell *)cell forGroup:(ExtracurricularStructure *)groupStructure {
     cell.textLabel.text = groupStructure.titleString;
     cell.textLabel.numberOfLines = 0;
     cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     /*AddGroupButton *addButton = [AddGroupButton buttonWithType:UIButtonTypeContactAdd];
     [addButton setEnabled:YES];
     [addButton sizeToFit];
     addButton.group = groupStructure;
     [addButton addTarget:self
                     action:@selector(addGroup:)
           forControlEvents:UIControlEventTouchUpInside];
     [addButton setFrame:CGRectMake(0, 0, addButton.frame.size.width, addButton.frame.size.height)];
     cell.accessoryView = addButton;
     [cell setNeedsLayout];*/
     return cell;
}

- (void)addGroup:(id)sender {
     AddGroupButton *button = (AddGroupButton *)sender;
     ExtracurricularStructure *EC = button.group;
     UIAlertView *subscribeAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[[@"Are you sure you want to subscribe to the group \"" stringByAppendingString:EC.titleString] stringByAppendingString:@"\"?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Subscribe", nil];
     [subscribeAlertView setDelegate:self];
     subscribeAlertView.tag = [EC.extracurricularID integerValue];
     [subscribeAlertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (buttonIndex == 1) {
               //Yes
          NSInteger index = actionSheet.tag;
          ExtracurricularStructure *EC = [self.groups objectAtIndex:[self getIndexofStructureWithID:[NSNumber numberWithInteger:index]]];
          activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          [self changeGroupMethodWithCompletion:^(NSError *error) {
               [activity stopAnimating];
               ExtracurricularsTableViewController *controller = (ExtracurricularsTableViewController *)[[self.navigationController viewControllers] objectAtIndex:(self.navigationController.viewControllers.count - 2)];
               controller.loadNumber = [NSNumber numberWithInt:1];
               [self.navigationController popViewControllerAnimated:YES];
          } forID:[@"E" stringByAppendingString:[EC.extracurricularID stringValue]] forAction:1];
     }
}

- (void)changeGroupMethodWithCompletion:(void (^)(NSError *error))completion forID:(NSString *)channel forAction:(NSInteger)action {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *currentChannels = [[[PFInstallation currentInstallation] objectForKey:@"channels"] mutableCopy];
     if (action == 0) {
               //Remove
          [currentChannels removeObject:channel];
     } else if (action == 1) {
          [currentChannels addObject:channel];
     }
     [[PFInstallation currentInstallation] setObject:currentChannels forKey:@"channels"];
     [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
          theError = error;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(theError);
     });
}

- (NSInteger)getIndexofStructureWithID:(NSNumber *)theID {
     for (int i = 0; i < self.groups.count; i++) {
          if (((ExtracurricularStructure *)(self.groups[i])).extracurricularID == theID)
               return i;
     }
     return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
