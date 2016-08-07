//
//  GroupDetailViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 2/15/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "GroupDetailViewController.h"

@interface GroupDetailViewController ()

@end

@implementation GroupDetailViewController {
     UILabel *titleLabel;
     UITextView *messageLabel;
     UITableView *theTableView;
     UIActivityIndicatorView *activity;
     UIAlertView *subscribeAlertView;
     UIAlertView *unsubscribeAlertView;
     UIAlertView *noAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     self.navigationItem.title = @"Group Details";
     
     UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     titleLabel.text = self.EC.titleString;
     [titleLabel setFont:[UIFont systemFontOfSize:24]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     summaryLabel.text = self.EC.userString;
     UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
     [summaryLabel setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
     summaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
     summaryLabel.numberOfLines = 0;
     [summaryLabel sizeToFit];
     [scrollView addSubview:summaryLabel];
     
     UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, summaryLabel.frame.origin.y + summaryLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
     messageLabel.text = self.EC.descriptionString;
     messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
     messageLabel.editable = false;
     messageLabel.scrollEnabled = false;
     [messageLabel setFont:[UIFont systemFontOfSize:16]];
     [messageLabel sizeToFit];
     [scrollView addSubview:messageLabel];
     
     theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, messageLabel.frame.origin.y + messageLabel.frame.size.height, self.view.frame.size.width, 90) style:UITableViewStyleGrouped];
     [theTableView setDelegate:self];
     [theTableView setDataSource:self];
     theTableView.scrollEnabled = false;
     [theTableView setBackgroundColor:[UIColor whiteColor]];
     [scrollView addSubview:theTableView];
     [theTableView reloadData];
     
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 70, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
     return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
     return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     NSMutableArray *currentChannels = [[[PFInstallation currentInstallation] objectForKey:@"channels"] mutableCopy];
     if ([currentChannels containsObject:[@"E" stringByAppendingString:[self.EC.extracurricularID stringValue]]]) {
          cell.textLabel.textColor = [UIColor redColor];
          cell.textLabel.text = @"Unsubscribe";
     } else {
          cell.textLabel.textColor = self.view.tintColor;
          cell.textLabel.text = @"Subscribe";
     }/*
     [[PFInstallation currentInstallation] setObject:currentChannels forKey:@"channels"];
     [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
          theError = error;
          dispatch_group_leave(serviceGroup);
     }];*/
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
      NSMutableArray *currentChannels = [[[PFInstallation currentInstallation] objectForKey:@"channels"] mutableCopy];
     if ([currentChannels containsObject:[@"E" stringByAppendingString:[self.EC.extracurricularID stringValue]]]) {
          unsubscribeAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[[@"Are you sure you want to unsubscribe from the group \"" stringByAppendingString:self.EC.titleString] stringByAppendingString:@"\"?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Unsubscribe", nil];
          [unsubscribeAlertView show];
     } else {
          subscribeAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[[@"Are you sure you want to subscribe to the group \"" stringByAppendingString:self.EC.titleString] stringByAppendingString:@"\"?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Subscribe", nil];
          [subscribeAlertView show];
     }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (actionSheet == unsubscribeAlertView) {
          if (buttonIndex == 1) {
                    //Yes
               NSString *string = [[PFInstallation currentInstallation] objectForKey:@"deviceToken"];
               
               if (string == nil) {
                    noAlertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You have not enabled push notifications for this device. Please turn on notifications in your iPhone settings, close the app and try to subscribe again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [noAlertView show];
               } else {
                    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    [activity setBackgroundColor:[UIColor clearColor]];
                    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                    [activity startAnimating];
                    [self changeGroupMethodWithCompletion:^(NSError *error) {
                         [activity stopAnimating];
                         [theTableView reloadData];
                    } forID:[@"E" stringByAppendingString:[self.EC.extracurricularID stringValue]] forAction:0];
               }
          }
          
     } else if (actionSheet == subscribeAlertView) {
          if (buttonIndex == 1) {
               NSString *string = [[PFInstallation currentInstallation] objectForKey:@"deviceToken"];
               
               if (string == nil) {
                    noAlertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You have not enabled push notifications for this device. Please turn on notifications in your iPhone settings, close the app and try to subscribe again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [noAlertView show];
               } else {
                         //Yes
                    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    [activity setBackgroundColor:[UIColor clearColor]];
                    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                    [activity startAnimating];
                    [self changeGroupMethodWithCompletion:^(NSError *error) {
                         [activity stopAnimating];
                         [theTableView reloadData];
                    } forID:[@"E" stringByAppendingString:[self.EC.extracurricularID stringValue]] forAction:1];
               }
          }
          
     } else if (actionSheet == noAlertView) {
          [self.navigationController popViewControllerAnimated:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (instancetype)init {
     [super init];
     self.navigationItem.title = @"Group Details";
     return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
