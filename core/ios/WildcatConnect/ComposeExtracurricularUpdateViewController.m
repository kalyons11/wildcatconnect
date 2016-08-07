//
//  ComposeExtracurricularUpdateViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/13/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "ComposeExtracurricularUpdateViewController.h"
#import <Parse/Parse.h>
#import "ExtracurricularStructure.h"
#import "ExtracurricularUpdateStructure.h"
#import "RegisterExtracurricularViewController.h"

#define kTabBarHeight 1

@interface ComposeExtracurricularUpdateViewController ()

@end

@implementation ComposeExtracurricularUpdateViewController {
     UIScrollView *scrollView;
     UILabel *titleLabel;
     UIPickerView *extracurricularPickerView;
     UILabel *messageRemainingLabel;
     UITextView *messageTextView;
     UITextView *titleTextView;
     BOOL hasChanged;
     UIView *separator;
     UIButton *postButton;
     UIAlertView *postAlertView;
     UIAlertView *errorAlertView;
     BOOL keyboardIsShown;
     UITableView *theTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     hasChanged = false;
     
     self.groupArray = [[NSMutableArray alloc] init];
     
          //UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
          //style:UIBarButtonItemStylePlain
          //target:self
          //action:@selector(goBack:)];
     
          //self.navigationItem.leftBarButtonItem = bbtnBack;
          //[bbtnBack release];
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     self.navigationItem.title = @"Group Update";
     self.navigationController.navigationBar.translucent = NO;
     
     hasChanged = false;
     
     UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(goBack:)];
     
     self.navigationItem.leftBarButtonItem = bbtnBack;
     
     [super viewDidLoad];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(keyboardWillShow:)
                                                  name:UIKeyboardWillShowNotification
                                                object:self.view.window];
          // register for keyboard notifications
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(keyboardWillHide:)
                                                  name:UIKeyboardWillHideNotification
                                                object:self.view.window];
     keyboardIsShown = NO;
     
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
     
     UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 50)];
     titleLabel.text = @"Loading, please wait...";
     [titleLabel setFont:[UIFont systemFontOfSize:16]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 10, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
     
     [self getExtracurricularsMethodWithCompletion:^(NSMutableArray *returnArray, NSError *error) {
          if (error != nil) {
               errorAlertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [errorAlertView show];
          } else {
               if (returnArray.count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [activity stopAnimating];
                         
                         [scrollView removeFromSuperview];
                         [titleLabel removeFromSuperview];
                         titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 50)];
                         titleLabel.text = @"You are not the owner of any Extracurricular groups. However, you can register a new group, where you will be able to send push notifications to users who subscribe.";
                         [titleLabel setFont:[UIFont systemFontOfSize:16]];
                         titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                         titleLabel.numberOfLines = 0;
                         [titleLabel sizeToFit];
                         [scrollView addSubview:titleLabel];
                         
                         UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeSystem];
                         [registerButton setTitle:@"REGISTER A NEW GROUP" forState:UIControlStateNormal];
                         [registerButton sizeToFit];
                         [registerButton addTarget:self action:@selector(registerMethod) forControlEvents:UIControlEventTouchUpInside];
                         registerButton.frame = CGRectMake(self.view.frame.size.width / 2 - registerButton.frame.size.width / 2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, registerButton.frame.size.width, registerButton.frame.size.height);
                         [scrollView addSubview:registerButton];
                         
                         self.automaticallyAdjustsScrollViewInsets = YES;
                         UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 10, 0);
                         scrollView.contentInset = adjustForTabbarInsets;
                         scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                         CGRect contentRect = CGRectZero;
                         for (UIView *view in scrollView.subviews) {
                              contentRect = CGRectUnion(contentRect, view.frame);
                         }
                         scrollView.contentSize = contentRect.size;
                         
                         [self.view addSubview:scrollView];
                    });
               } else {
                    self.ECarray = returnArray;
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [activity stopAnimating];
                         titleLabel.text = @"Select Group(s)";
                         [titleLabel sizeToFit];
                         
                         theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width, 250)];
                         [theTableView setDelegate:self];
                         [theTableView setDataSource:self];
                         [scrollView addSubview:theTableView];
                         
                         UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, theTableView.frame.origin.y + theTableView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
                         messageLabel.text = @"Message";
                         [messageLabel setFont:[UIFont systemFontOfSize:16]];
                         messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
                         messageLabel.numberOfLines = 0;
                         [messageLabel sizeToFit];
                         [scrollView addSubview:messageLabel];
                         
                         messageRemainingLabel = [[UILabel alloc] init];
                         messageRemainingLabel.text = @"140 characters remaining";
                         [messageRemainingLabel setFont:[UIFont systemFontOfSize:10]];
                         [messageRemainingLabel sizeToFit];
                         messageRemainingLabel.frame = CGRectMake((self.view.frame.size.width - messageRemainingLabel.frame.size.width - 10), messageLabel.frame.origin.y, messageRemainingLabel.frame.size.width, 20);
                         [scrollView addSubview:messageRemainingLabel];
                         
                         messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y + messageLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
                         [messageTextView setDelegate:self];
                         [messageTextView setFont:[UIFont systemFontOfSize:16]];
                         messageTextView.layer.borderWidth = 1.0f;
                         messageTextView.layer.borderColor = [[UIColor grayColor] CGColor];
                         messageTextView.scrollEnabled = false;
                         [scrollView addSubview:messageTextView];
                         
                         separator = [[UIView alloc] initWithFrame:CGRectMake(10, messageTextView.frame.origin.y + messageTextView.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                         separator.backgroundColor = [UIColor blackColor];
                         [scrollView addSubview:separator];
                         
                         postButton = [UIButton buttonWithType:UIButtonTypeSystem];
                         [postButton setTitle:@"POST UPDATE" forState:UIControlStateNormal];
                         [postButton sizeToFit];
                         [postButton addTarget:self action:@selector(postUpdate) forControlEvents:UIControlEventTouchUpInside];
                         postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
                         [scrollView addSubview:postButton];
                         
                         self.automaticallyAdjustsScrollViewInsets = YES;
                         UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 150, 0);
                         scrollView.contentInset = adjustForTabbarInsets;
                         scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                         CGRect contentRect = CGRectZero;
                         for (UIView *view in scrollView.subviews) {
                              contentRect = CGRectUnion(contentRect, view.frame);
                         }
                         scrollView.contentSize = contentRect.size;
                         
                         [self.view addSubview:scrollView];
                    });
               }
          }
     }];
     
}

- (void)registerMethod {
     RegisterExtracurricularViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterEC"];
     [self.navigationController pushViewController:controller animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)n
{
     
     scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     
     keyboardIsShown = NO;
     
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 150, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
}

- (void)keyboardWillShow:(NSNotification *)n
{
          // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView` if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`, scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.  If we were to resize the `UIScrollView` again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
     if (keyboardIsShown) {
          return;
     }
     
     NSDictionary* userInfo = [n userInfo];
     
          // get the size of the keyboard
     CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
     
          // resize the noteView
     CGRect viewFrame = scrollView.frame;
          // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
     viewFrame.size.height -= (keyboardSize.height - 1);
     
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationBeginsFromCurrentState:YES];
     [scrollView setFrame:viewFrame];
     [UIView commitAnimations];
     keyboardIsShown = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     ExtracurricularStructure *EC = (ExtracurricularStructure *)[self.ECarray objectAtIndex:indexPath.row];
     UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
     [switchView setOn:NO animated:NO];
     [switchView setTag:[EC.extracurricularID integerValue]];
     [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
     cell.accessoryView = switchView;
     cell.textLabel.text = EC.titleString;
     return cell;
}

- (void)switchChanged:(id)sender {
     hasChanged = true;
     UISwitch *switchControl = (UISwitch *)sender;
     if (switchControl.on == true) {
          [self.groupArray addObject:[NSNumber numberWithInteger:switchControl.tag]];
     } else if (switchControl.on == false) {
          [self.groupArray removeObject:[NSNumber numberWithInteger:switchControl.tag]];
     }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (self.ECarray.count == 0) {
          return 1;
     } else
          return self.ECarray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (void)postUpdateMethodWithCompletion:(void (^)(NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *finalArray = [[NSMutableArray alloc] init];
     PFQuery *query = [ExtracurricularUpdateStructure query];
     [query orderByDescending:@"extracurricularUpdateID"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          NSInteger firstIndex = [[object objectForKey:@"extracurricularUpdateID"] integerValue];
          for (int i = 0; i < self.groupArray.count; i++) {
               ExtracurricularUpdateStructure *extracurricularUpdateStructure = [[ExtracurricularUpdateStructure alloc] init];
               extracurricularUpdateStructure.extracurricularID = [self.groupArray objectAtIndex:i];
               extracurricularUpdateStructure.messageString = messageTextView.text;
               extracurricularUpdateStructure.extracurricularUpdateID = [NSNumber numberWithInteger:firstIndex + 1 + i];
               extracurricularUpdateStructure.postDate = [NSDate date];
               [finalArray addObject:extracurricularUpdateStructure];
          }
          [PFObject saveAllInBackground:finalArray block:^(BOOL succeeded, NSError * _Nullable error) {
               if (error) {
                    theError = error;
               }
               dispatch_group_leave(serviceGroup);
          }];
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(theError);
     });
}

- (void)postUpdate {
     if (! [self validateAllFields]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please ensure you have correctly filled out all fields!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alertView show];
     } else {
          postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to post this group update? It will be live to all subscribed users." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [postAlertView show];
     }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to this community service update will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
}

- (BOOL)validateAllFields {
     return (self.groupArray.count > 0 && messageTextView.text.length > 0);
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (actionSheet == postAlertView) {
          if (buttonIndex == 1) {
               UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, postButton.frame.origin.y, 30, 30)];
               [postButton removeFromSuperview];
               [activity setBackgroundColor:[UIColor clearColor]];
               [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
               [scrollView addSubview:activity];
               [activity startAnimating];
               [self postUpdateMethodWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [activity stopAnimating];
                         NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"];
                         if ([array containsObject:[NSString stringWithFormat:@"%lu", (long)1]]) {
                              NSMutableArray *newArray = [array mutableCopy];
                              [newArray removeObject:[NSString stringWithFormat:@"%lu", (long)1]];
                              [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"visitedPagesArray"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                         }
                         [self.navigationController popViewControllerAnimated:YES];
                    });
               }];
          }
          
     } else if (actionSheet == errorAlertView) {
          if (buttonIndex == 0) {
               [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
          }
     }
     else {
          if (buttonIndex == 1) {
               [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
          }
     }
}

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to this article will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
     else {
          [self.navigationController popViewControllerAnimated:YES];
     }
}

-(void)textViewDidChange:(UITextView *)textView
{
     hasChanged = true;
     if (textView == messageTextView) {
          int len = textView.text.length;
          if (140 - len <= 10) {
               if (140 - len == 1) {
                    messageRemainingLabel.text= [[NSString stringWithFormat:@"%i",140-len] stringByAppendingString:@" character remaining"];
               } else {
                    
                    messageRemainingLabel.text= [[NSString stringWithFormat:@"%i",140-len] stringByAppendingString:@" characters remaining"];
               }
               messageRemainingLabel.textColor = [UIColor redColor];
               [messageRemainingLabel sizeToFit];
               messageRemainingLabel.frame = CGRectMake((self.view.frame.size.width - messageRemainingLabel.frame.size.width - 10), messageRemainingLabel.frame.origin.y, messageRemainingLabel.frame.size.width, 20);
          } else {
               messageRemainingLabel.text= [[NSString stringWithFormat:@"%i",140-len] stringByAppendingString:@" characters remaining"];
               messageRemainingLabel.textColor = [UIColor blackColor];
               [messageRemainingLabel sizeToFit];
               messageRemainingLabel.frame = CGRectMake((self.view.frame.size.width - messageRemainingLabel.frame.size.width - 10), messageRemainingLabel.frame.origin.y, messageRemainingLabel.frame.size.width, 20);
          }
     }
}

- (BOOL)isAcceptableTextLength:(NSUInteger)length forMaximum:(NSUInteger)maximum existsMaximum:(BOOL)exists {
     if (exists) {
          return length <= maximum;
     }
     else return true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
     if (textView == messageTextView) {
          if([string isEqualToString:@"\n"])
          {
               [textView resignFirstResponder];
               
               return NO;
          } else
               return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:140 existsMaximum:YES];
     }
     else return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
          // Handle the selection
     if (row == 0) {
          self.EC = nil;
     } else {
          self.EC = (ExtracurricularStructure *)self.ECarray[row - 1];
     }
}

     // tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
     
     return self.ECarray.count + 1;
     
}

     // tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
     return 1;
}

     // tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
     
     if (row == 0) {
          return @"SELECT";
     } else {
          ExtracurricularStructure *EC = (ExtracurricularStructure *)self.ECarray[row - 1];
          
          return EC.titleString;
     }
}

     // tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
     int sectionWidth = 300;
     
     return sectionWidth;
}

- (void)getExtracurricularsMethodWithCompletion:(void (^)(NSMutableArray *returnArray, NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *returnArray = [NSMutableArray array];
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          PFQuery *query = [ExtracurricularStructure query];
          [query orderByAscending:@"titleString"];
          [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
               [returnArray addObjectsFromArray:objects];
               theError = error;
               dispatch_group_leave(serviceGroup);
          }];
     } else {
          [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
               PFUser *currentUser = (PFUser *)object;
               NSArray *ECArray = [currentUser objectForKey:@"ownedEC"];
               PFQuery *query = [ExtracurricularStructure query];
               [query whereKey:@"extracurricularID" containedIn:ECArray];
               [query orderByAscending:@"titleString"];
               [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    [returnArray addObjectsFromArray:objects];
                    theError = error;
                    dispatch_group_leave(serviceGroup);
               }];
          }];
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(returnArray, overallError);
     });
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
