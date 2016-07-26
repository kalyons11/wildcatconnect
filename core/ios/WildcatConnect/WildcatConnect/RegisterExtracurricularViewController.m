//
//  RegisterExtracurricularViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/15/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "RegisterExtracurricularViewController.h"
#import "ExtracurricularStructure.h"

@interface RegisterExtracurricularViewController ()

@end

@implementation RegisterExtracurricularViewController {
     BOOL hasChanged;
     BOOL keyboardIsShown;
     UIScrollView *scrollView;
     UILabel *titleLabel;
     UIView *separator;
     UITextView *titleTextView;
     UITextView *descriptionTextView;
     UILabel *messageRemainingLabel;
     UITableView *theTableView;
     UIButton *postButton;
     UIAlertView *postAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.meetingString = @"";
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     self.navigationItem.title = @"New Group";
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
      
      UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
      messageLabel.text = @"Group Title";
      [messageLabel setFont:[UIFont systemFontOfSize:16]];
      messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
      messageLabel.numberOfLines = 0;
      [messageLabel sizeToFit];
      [scrollView addSubview:messageLabel];
      
      titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y + messageLabel.frame.size.height + 10, self.view.frame.size.width - 20, 70)];
      [titleTextView setDelegate:self];
      [titleTextView setFont:[UIFont systemFontOfSize:16]];
      titleTextView.layer.borderWidth = 1.0f;
      titleTextView.layer.borderColor = [[UIColor grayColor] CGColor];
      titleTextView.scrollEnabled = false;
      [scrollView addSubview:titleTextView];
     
     UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleTextView.frame.origin.y + titleTextView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     descriptionLabel.text = @"Group Information";
     [descriptionLabel setFont:[UIFont systemFontOfSize:16]];
     descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
     descriptionLabel.numberOfLines = 0;
     [descriptionLabel sizeToFit];
     [scrollView addSubview:descriptionLabel];
     
     messageRemainingLabel = [[UILabel alloc] init];
     messageRemainingLabel.text = @"400 characters remaining";
     [messageRemainingLabel setFont:[UIFont systemFontOfSize:10]];
     [messageRemainingLabel sizeToFit];
     messageRemainingLabel.frame = CGRectMake((self.view.frame.size.width - messageRemainingLabel.frame.size.width - 10), descriptionLabel.frame.origin.y, messageRemainingLabel.frame.size.width, 20);
     [scrollView addSubview:messageRemainingLabel];
     
     UILabel *descriptionLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     UIFont *font = [UIFont systemFontOfSize:12];
     [descriptionLabelB setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
     descriptionLabelB.text = @"Purpose, advisor(s), meeting times and locations, etc.";
     descriptionLabelB.lineBreakMode = NSLineBreakByWordWrapping;
     descriptionLabelB.numberOfLines = 0;
     [descriptionLabelB sizeToFit];
     [scrollView addSubview:descriptionLabelB];
     
     descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(messageLabel.frame.origin.x, descriptionLabelB.frame.origin.y + descriptionLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 150)];
     [descriptionTextView setDelegate:self];
     [descriptionTextView setFont:[UIFont systemFontOfSize:16]];
     descriptionTextView.layer.borderWidth = 1.0f;
     descriptionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     descriptionTextView.scrollEnabled = true;
     [scrollView addSubview:descriptionTextView];
     
     UILabel *meetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, descriptionTextView.frame.origin.y + descriptionTextView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     meetingLabel.text = @"Meeting Days (if applicable)";
     [meetingLabel setFont:[UIFont systemFontOfSize:16]];
     meetingLabel.lineBreakMode = NSLineBreakByWordWrapping;
     meetingLabel.numberOfLines = 0;
     [meetingLabel sizeToFit];
     [scrollView addSubview:meetingLabel];
     
     theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, meetingLabel.frame.origin.y + meetingLabel.frame.size.height + 10, self.view.frame.size.width, 250)];
     [theTableView setDelegate:self];
     [theTableView setDataSource:self];
     [scrollView addSubview:theTableView];
     [theTableView reloadData];
     
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, theTableView.frame.origin.y + theTableView.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     postButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [postButton setTitle:@"REGISTER GROUP" forState:UIControlStateNormal];
     [postButton sizeToFit];
     [postButton addTarget:self action:@selector(registerMethod) forControlEvents:UIControlEventTouchUpInside];
     postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
     [scrollView addSubview:postButton];
     
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

- (void)registerMethod {
     if (! [self validateAllFields]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please ensure you have correctly filled out all fields!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alertView show];
     } else {
          postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to register this group?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [postAlertView show];
     }
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
               [self postECMethodWithCompletion:^(NSError *error, NSInteger response) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [activity stopAnimating];
                         if (response == 1) {
                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"A group with this name has already been registered. Please enter a different name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                              [alertView show];
                              postButton = [UIButton buttonWithType:UIButtonTypeSystem];
                              [postButton setTitle:@"REGISTER GROUP" forState:UIControlStateNormal];
                              [postButton sizeToFit];
                              [postButton addTarget:self action:@selector(registerMethod) forControlEvents:UIControlEventTouchUpInside];
                              postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
                              [scrollView addSubview:postButton];
                         } else {
                              NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"];
                              if ([array containsObject:[NSString stringWithFormat:@"%lu", (long)1]]) {
                                   NSMutableArray *newArray = [array mutableCopy];
                                   [newArray removeObject:[NSString stringWithFormat:@"%lu", (long)1]];
                                   [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"visitedPagesArray"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                              }
                              [self.navigationController popViewControllerAnimated:YES];
                         }
                    });
               }];
          }
          
     } else {
          if (buttonIndex == 1) {
               [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
          }
     }
}

- (void)postECMethodWithCompletion:(void (^)(NSError *error, NSInteger response))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSInteger response;
     ExtracurricularStructure *EC = [[ExtracurricularStructure alloc] init];
     EC.hasImage = [NSNumber numberWithInt:0];
     EC.descriptionString = descriptionTextView.text;
     EC.titleString = titleTextView.text;
     EC.meetingIDs = self.meetingString;
     NSString *firstName = [[PFUser currentUser] objectForKey:@"firstName"];
     NSString *lastName = [[PFUser currentUser] objectForKey:@"lastName"];
     EC.userString = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
     PFQuery *query = [ExtracurricularStructure query];
     [query orderByDescending:@"extracurricularID"];
     [query whereKey:@"titleString" equalTo:EC.titleString];
     [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
          if (number > 0) {
               response = 1;
               dispatch_group_leave(serviceGroup);
          } else {
               PFQuery *queryTwo = [ExtracurricularStructure query];
               [queryTwo orderByDescending:@"extracurricularID"];
               [queryTwo getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    ExtracurricularStructure *structure = (ExtracurricularStructure *)object;
                    if (structure) {
                         EC.extracurricularID = [NSNumber numberWithInteger:[structure.extracurricularID integerValue] + 1];
                    } else
                         EC.extracurricularID = [NSNumber numberWithInt:0];
                    [EC saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                         if (error) {
                              theError = error;
                              response = 0;
                         }
                         NSMutableArray *array = [[[PFUser currentUser] objectForKey:@"ownedEC"] mutableCopy];
                         [array addObject:EC.extracurricularID];
                         [[PFUser currentUser] setObject:array forKey:@"ownedEC"];
                         [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                              if (error) {
                                   theError = error;
                                   response = 0;
                              }
                              dispatch_group_leave(serviceGroup);
                         }];
                    }];
               }];
          }
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(theError, response);
     });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
     [switchView setOn:NO animated:NO];
     [switchView setTag:indexPath.row];
     [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
     if (indexPath.row == 0) {
          cell.textLabel.text = @"Monday";
     } else if (indexPath.row == 1) {
          cell.textLabel.text = @"Tuesday";
     } else if (indexPath.row == 2) {
          cell.textLabel.text = @"Wednesday";
     } else if (indexPath.row == 3) {
          cell.textLabel.text = @"Thursday";
     } else if (indexPath.row == 4) {
          cell.textLabel.text = @"Friday";
     }
     cell.accessoryView = switchView;
     return cell;
}

- (void)switchChanged:(id)sender {
     hasChanged = true;
     UISwitch *switchControl = (UISwitch *)sender;
     if (switchControl.on == true) {
          self.meetingString = [self.meetingString stringByAppendingString:[[NSNumber numberWithInteger:switchControl.tag] stringValue]];
     } else if (switchControl.on == false) {
          self.meetingString = [self.meetingString stringByReplacingOccurrencesOfString:[[NSNumber numberWithInteger:switchControl.tag] stringValue] withString:@""];
     }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (BOOL)validateAllFields {
     if (self.meetingString.length == 0) {
          self.meetingString = @"None.";
     }
     return (titleTextView.text.length > 0 && descriptionTextView.text.length > 0 && self.meetingString.length > 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to this group will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
     else {
          [self.navigationController popViewControllerAnimated:YES];
     }
}

- (void)keyboardWillHide:(NSNotification *)n
{
     
     scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     
     keyboardIsShown = NO;
     
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 70, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
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

-(void)textViewDidChange:(UITextView *)textView
{
     hasChanged = true;
     if (textView == descriptionTextView) {
          int len = textView.text.length;
          if (400 - len <= 10) {
               if (400 - len == 1) {
                    messageRemainingLabel.text= [[NSString stringWithFormat:@"%i",400-len] stringByAppendingString:@" character remaining"];
               } else {
                    messageRemainingLabel.text= [[NSString stringWithFormat:@"%i",400-len] stringByAppendingString:@" characters remaining"];
               }
               messageRemainingLabel.textColor = [UIColor redColor];
               [messageRemainingLabel sizeToFit];
               messageRemainingLabel.frame = CGRectMake((self.view.frame.size.width - messageRemainingLabel.frame.size.width - 10), messageRemainingLabel.frame.origin.y, messageRemainingLabel.frame.size.width, 20);
          } else {
               messageRemainingLabel.text= [[NSString stringWithFormat:@"%i",400-len] stringByAppendingString:@" characters remaining"];
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
     if (textView == titleTextView) {
          if([string isEqualToString:@"\n"])
          {
               [textView resignFirstResponder];
               
               return NO;
          } else
               return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:40  existsMaximum:YES];
     } else if (textView == descriptionTextView) {
          if([string isEqualToString:@"\n"])
          {
               [textView resignFirstResponder];
               
               return NO;
          } else
               return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:400 existsMaximum:YES];
     }
     else return nil;
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
