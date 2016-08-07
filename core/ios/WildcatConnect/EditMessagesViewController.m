//
//  EditMessagesViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/17/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "EditMessagesViewController.h"
#import "SchoolDayStructure.h"
#import <Parse/Parse.h>

@interface EditMessagesViewController ()

@end

@implementation EditMessagesViewController {
     UIActivityIndicatorView *activity;
     UIScrollView *scrollView;
     UILabel *titleLabel;
     NSString *messageString;
     NSString *schoolDayID;
     UITextView *messageTextView;
     UIButton *postButton;
     BOOL keyboardIsShown;
     BOOL hasChanged;
     UIAlertView *postAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     hasChanged = false;
     
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
     
     messageString = [[NSString alloc] init];
     schoolDayID = [[NSString alloc] init];
     
     UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(goBack:)];
     
     self.navigationItem.leftBarButtonItem = bbtnBack;
     
     self.navigationItem.title = @"Messages";
     
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
     
     self.navigationController.navigationBar.translucent = NO;
     
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 50)];
     titleLabel.text = @"Loading today's messages...";
     [titleLabel setFont:[UIFont systemFontOfSize:16]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     [self getCurrentSchoolDayMethodWithCompletion:^(NSError *error, NSMutableArray *schoolDay) {
          if (error != nil) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewDidLoad)];
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                    [activity startAnimating];
               });
          } else {
               [activity stopAnimating];
               schoolDayID = [[schoolDay objectAtIndex:0] objectForKey:@"schoolDayID"];
               messageString = [[schoolDay objectAtIndex:0] objectForKey:@"messageString"];
               
               titleLabel.text = @"Today's Messages";
               [titleLabel sizeToFit];
               
               messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 200)];
               messageTextView.text = messageString;
               messageTextView.editable = true;
               messageTextView.scrollEnabled = true;
               [messageTextView setDelegate:self];
               [messageTextView setFont:[UIFont systemFontOfSize:16]];
               messageTextView.layer.borderWidth = 1.0f;
               messageTextView.layer.borderColor = [[UIColor grayColor] CGColor];
               messageTextView.dataDetectorTypes = UIDataDetectorTypeLink;
               [scrollView addSubview:messageTextView];
               
               postButton = [UIButton buttonWithType:UIButtonTypeSystem];
               [postButton setTitle:@"SAVE MESSAGES" forState:UIControlStateNormal];
               [postButton sizeToFit];
               [postButton addTarget:self action:@selector(saveMessages) forControlEvents:UIControlEventTouchUpInside];
               postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), messageTextView.frame.origin.y + messageTextView.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
               [scrollView addSubview:postButton];
          }
     }];
     
          //self.automaticallyAdjustsScrollViewInsets = YES;
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

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to today's messages will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
     else {
          [self.navigationController popViewControllerAnimated:YES];
     }
}

- (void)saveMessagesMethodWithCompletion:(void (^)(NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [SchoolDayStructure query];
     [query whereKey:@"schoolDayID" equalTo:schoolDayID];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          SchoolDayStructure *structure = (SchoolDayStructure *)object;
          structure.messageString = messageTextView.text;
          [structure saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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

-(void)textViewDidChange:(UITextView *)textView
{
     hasChanged = true;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (actionSheet == postAlertView) {
          if (buttonIndex == 1) {
               UIActivityIndicatorView *theActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, postButton.frame.origin.y, 30, 30)];
               [theActivity setBackgroundColor:[UIColor clearColor]];
               [theActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
               [scrollView addSubview:theActivity];
               [theActivity startAnimating];
               [self saveMessagesMethodWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [theActivity stopAnimating];
                              //Add reload feature for home page...
                         [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         [self.navigationController popViewControllerAnimated:YES];
                    });
               }];
          }
          
     }
     else {
          if (buttonIndex == 1) {
               [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
          }
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

- (void)saveMessages {
          postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to save these messages? They will be live to all app users. Please avoid deleting pre-existing messages." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [postAlertView show];
}

- (void)getCurrentSchoolDayMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *schoolDay))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [SchoolDayStructure query];
     [query orderByDescending:@"schoolDayID"];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          theError = error;
          [array addObjectsFromArray:objects];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, array);
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
