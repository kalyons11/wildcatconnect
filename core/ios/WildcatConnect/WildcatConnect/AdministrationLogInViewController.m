//
//  AdministrationLogInViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/4/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "AdministrationLogInViewController.h"
#import <Parse/Parse.h>
#import "AdministrationMainTableViewController.h"
#import "UserRegisterStructure.h"
#include <stdlib.h>

@interface AdministrationLogInViewController ()

@end

@implementation AdministrationLogInViewController {
     BOOL hasChanged;
     BOOL keyboardIsShown;
     UIScrollView *scrollView;
     UITextField *usernameTextField;
     UITextField *passwordTextField;
     UITextField *firstNameTextField;
     UITextField *lastNameTextField;
     UITextField *emailTextField;
     UITextField *confirmEmailTextField;
     UITextField *regUsernameTextField;
     UITextField *regPasswordTextField;
     UITextField *confirmRegPasswordTextField;
     UIButton *logButton;
     UIButton *forgotButton;
     UIButton *signButton;
     UIAlertView *av;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     hasChanged = false;
     
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
     
     self.navigationItem.title = @"Account";
     self.navigationController.navigationBar.translucent = NO;
     
     UILabel *titleLabel = [[UILabel alloc] init];
     titleLabel.text = @"Log In";
     [titleLabel setFont:[UIFont systemFontOfSize:16]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     titleLabel.frame = CGRectMake((self.view.frame.size.width / 2 - titleLabel.frame.size.width / 2), 10, titleLabel.frame.size.width, titleLabel.frame.size.height);
     [scrollView addSubview:titleLabel];
     
     usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
     usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
     usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
     usernameTextField.placeholder = @"Username";
     usernameTextField.tag = 0;
     [usernameTextField setDelegate:self];
     [scrollView addSubview:usernameTextField];
     
     passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(usernameTextField.frame.origin.x, usernameTextField.frame.origin.y + usernameTextField.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
     passwordTextField.placeholder = @"Password";
     passwordTextField.secureTextEntry = YES;
     passwordTextField.tag = 1;
     [passwordTextField setDelegate:self];
     [scrollView addSubview:passwordTextField];
     
     logButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [logButton setTitle:@"LOG IN" forState:UIControlStateNormal];
     [logButton sizeToFit];
     [logButton addTarget:self action:@selector(logIn) forControlEvents:UIControlEventTouchUpInside];
     logButton.frame = CGRectMake((self.view.frame.size.width / 2 - logButton.frame.size.width / 2), passwordTextField.frame.origin.y + passwordTextField.frame.size.height + 10, logButton.frame.size.width, logButton.frame.size.height);
     [scrollView addSubview:logButton];
     
     forgotButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [forgotButton setTitle:@"FORGOT USERNAME/PASSWORD" forState:UIControlStateNormal];
     [forgotButton sizeToFit];
     [forgotButton addTarget:self action:@selector(forgot) forControlEvents:UIControlEventTouchUpInside];
     forgotButton.frame = CGRectMake((self.view.frame.size.width / 2 - forgotButton.frame.size.width / 2), logButton.frame.origin.y + logButton.frame.size.height, forgotButton.frame.size.width, forgotButton.frame.size.height);
     [scrollView addSubview:forgotButton];
     
     UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, forgotButton.frame.origin.y + forgotButton.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     UILabel *signLabel = [[UILabel alloc] init];
     signLabel.text = @"Register an Account (Faculty Only)";
     [signLabel setFont:[UIFont systemFontOfSize:16]];
     signLabel.lineBreakMode = NSLineBreakByWordWrapping;
     signLabel.numberOfLines = 0;
     [signLabel sizeToFit];
     signLabel.frame = CGRectMake((self.view.frame.size.width / 2 - signLabel.frame.size.width / 2), separator.frame.origin.y + separator.frame.size.height + 10, signLabel.frame.size.width, signLabel.frame.size.height);
     [scrollView addSubview:signLabel];
     
     firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, signLabel.frame.origin.y + signLabel.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     firstNameTextField.borderStyle = UITextBorderStyleRoundedRect;
     firstNameTextField.placeholder = @"First Name";
     firstNameTextField.tag = 2;
     [firstNameTextField setDelegate:self];
     [scrollView addSubview:firstNameTextField];
     
     lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, firstNameTextField.frame.origin.y + firstNameTextField.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     lastNameTextField.borderStyle = UITextBorderStyleRoundedRect;
     lastNameTextField.placeholder = @"Last Name";
     lastNameTextField.tag = 3;
     [lastNameTextField setDelegate:self];
     [scrollView addSubview:lastNameTextField];
     
     emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, lastNameTextField.frame.origin.y + lastNameTextField.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     emailTextField.borderStyle = UITextBorderStyleRoundedRect;
     emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
     emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
     emailTextField.placeholder = @"Faculty E-Mail";
     emailTextField.tag = 4;
     [emailTextField setDelegate:self];
     [scrollView addSubview:emailTextField];
     
     confirmEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, emailTextField.frame.origin.y + emailTextField.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     confirmEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
     confirmEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
     confirmEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
     confirmEmailTextField.placeholder = @"Confirm Faculty E-Mail";
     confirmEmailTextField.tag = 5;
     [confirmEmailTextField setDelegate:self];
     [scrollView addSubview:confirmEmailTextField];
     
     regUsernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, confirmEmailTextField.frame.origin.y + confirmEmailTextField.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     regUsernameTextField.borderStyle = UITextBorderStyleRoundedRect;
     regUsernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
     regUsernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
     regUsernameTextField.placeholder = @"Username";
     regUsernameTextField.tag = 6;
     [regUsernameTextField setDelegate:self];
     [scrollView addSubview:regUsernameTextField];
     
     regPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(regUsernameTextField.frame.origin.x, regUsernameTextField.frame.origin.y + regUsernameTextField.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     regPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
     regPasswordTextField.placeholder = @"Create Password";
     regPasswordTextField.secureTextEntry = YES;
     regPasswordTextField.tag = 7;
     [regPasswordTextField setDelegate:self];
     [scrollView addSubview:regPasswordTextField];
     
     confirmRegPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(regPasswordTextField.frame.origin.x, regPasswordTextField.frame.origin.y + regPasswordTextField.frame.size.height + 10, self.view.frame.size.width - 20, 31)];
     confirmRegPasswordTextField.borderStyle = UITextBorderStyleRoundedRect;
     confirmRegPasswordTextField.placeholder = @"Confirm Password";
     confirmRegPasswordTextField.secureTextEntry = YES;
     confirmRegPasswordTextField.tag = 8;
     [confirmRegPasswordTextField setDelegate:self];
     [scrollView addSubview:confirmRegPasswordTextField];
     
     signButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [signButton setTitle:@"REGISTER" forState:UIControlStateNormal];
     [signButton sizeToFit];
     [signButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
     signButton.frame = CGRectMake((self.view.frame.size.width / 2 - signButton.frame.size.width / 2), confirmRegPasswordTextField.frame.origin.y + confirmRegPasswordTextField.frame.size.height + 10, signButton.frame.size.width, signButton.frame.size.height);
     [scrollView addSubview:signButton];
     
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 80, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
}

- (void)forgot {
     UIAlertView *theAlert = [[UIAlertView alloc]initWithTitle:@"Account Recovery" message:@"Please enter the e-mail address associated with your account." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Recover", nil];
     theAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
     [theAlert textFieldAtIndex:0].delegate = self;
     [theAlert setDelegate:self];
     [theAlert show];
}

- (BOOL) validateEmail: (NSString *) candidate {
     NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
     NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
     
     return [emailTest evaluateWithObject:candidate];
}

- (void)keyboardWillHide:(NSNotification *)n
{
     
     scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     
     keyboardIsShown = NO;
     
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 80, 0);
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

- (void)registerUser{
     NSString *username = regUsernameTextField.text;
     NSString *password = regPasswordTextField.text;
     NSString *confirmPassword = confirmRegPasswordTextField.text;
     NSString *firstName = firstNameTextField.text;
     NSString *lastName = lastNameTextField.text;
     NSString *email = emailTextField.text;
     NSString *confirmEmail = confirmEmailTextField.text;
     if ([username length] == 0 || [password length] == 0 || [firstName length] == 0 || [lastName length] == 0 || [email length] == 0 || [self validateEmail:email] == false) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Please ensure you have correctly filled out all required fields!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     } else if (! [email isEqualToString:confirmEmail]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Your e-mail addresses do not match!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     } else if (! [password isEqualToString:password]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Your passwords do not match!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     } /*else if (! [email containsString:@"weymouthschools.org"]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Your e-mail address is not a valid faculty address!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     }*/ else if ([username containsString:@" "]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Your username cannot contain any spaces!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     } else if ([password containsString:@" "]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Your password cannot contain any spaces!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     } else {
          UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 15, signButton.frame.origin.y, 30, 30)];
          [signButton removeFromSuperview];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          [scrollView addSubview:activity];
          [activity startAnimating];
          [self registerMethodWithCompletion:^(NSError *error, NSInteger response) {
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    if (response == 0) {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Error registering user. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                         [alertView show];
                         regUsernameTextField.text = @"";
                         regPasswordTextField.text = @"";
                         firstNameTextField.text = @"";
                         lastNameTextField.text = @"";
                         emailTextField.text = @"";
                         [self.navigationController popViewControllerAnimated:YES];
                    } else if (response == 1) {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"This username or e-mail has already been used. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                         [alertView show];
                         [activity removeFromSuperview];
                         signButton = [UIButton buttonWithType:UIButtonTypeSystem];
                         [signButton setTitle:@"REGISTER" forState:UIControlStateNormal];
                         [signButton sizeToFit];
                         [signButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
                         signButton.frame = CGRectMake((self.view.frame.size.width / 2 - signButton.frame.size.width / 2), regPasswordTextField.frame.origin.y + regPasswordTextField.frame.size.height + 10, signButton.frame.size.width, signButton.frame.size.height);
                         [scrollView addSubview:signButton];
                    } else if (response == 2) {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully registered your WildcatConnect account! A member of administration will approve your request and you will then receive a confirmation e-mail." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                         [alertView show];
                         regUsernameTextField.text = @"";
                         regPasswordTextField.text = @"";
                         firstNameTextField.text = @"";
                         lastNameTextField.text = @"";
                         emailTextField.text = @"";
                         [self.navigationController popViewControllerAnimated:YES];
                    }
               });
          } forDictionary:@{ @"username" : username , @"password" : password , @"firstName" : firstName , @"lastName" : lastName , @"email" : email }];
     }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
     NSInteger nextTag = textField.tag + 1;
          // Try to find next responder
     UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
     if (nextResponder) {
               // Found next responder, so set it.
          [nextResponder becomeFirstResponder];
     } else {
               // Not found, so remove keyboard.
          [textField resignFirstResponder];
     }
     return NO; // We do not want UITextField to insert line-breaks.
}

- (void)registerMethodWithCompletion:(void (^)(NSError *error, NSInteger response))completion forDictionary:(NSDictionary *)dictionary {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSInteger response = -1;
     [PFCloud callFunctionInBackground:@"validateUser" withParameters:@{ @"username" : [dictionary objectForKey:@"username"] , @"email" : [dictionary objectForKey:@"email"] } block:^(id  _Nullable object, NSError * _Nullable error) {
               //
          if ([object integerValue] > 0) {
               response = 1;
               dispatch_group_leave(serviceGroup);
          } else {
               [PFCloud callFunctionInBackground:@"encryptPassword" withParameters:@{ @"password" : [dictionary objectForKey:@"password"] } block:^(id  _Nullable object, NSError * _Nullable error) {
                    if (error != nil) {
                         theError = error;
                         response = 0;
                    }
                         //object contains the encrypted password
                    UserRegisterStructure *URS = [[UserRegisterStructure alloc] init];
                    URS.firstName = [dictionary objectForKey:@"firstName"];
                    URS.lastName = [dictionary objectForKey:@"lastName"];
                    URS.email = [dictionary objectForKey:@"email"];
                    URS.username = [dictionary objectForKey:@"username"];
                    URS.password = object;
                    URS.key =  [self randomStringWithLength:11];
                    [URS saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable errorTwo) {
                         if (errorTwo != nil) {
                              theError = errorTwo;
                              response = 0;
                         } else
                              response = 2;
                         dispatch_group_leave(serviceGroup);
                    }];
               }];
          }
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(theError, response);
     });
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) randomStringWithLength: (int) len {
     
     NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
     
     for (int i=0; i<len; i++) {
          [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
     }
     
     return randomString;
}

- (void)logIn {
     NSString *username = usernameTextField.text;
     NSString *password = passwordTextField.text;
     if ([username length] == 0 || [password length] == 0) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You must enter a valid username and password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     } else {
          UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
               if (! error) {
                    [activity stopAnimating];
                    if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Lunch Manager"]) {
                         [PFUser logOutInBackground];
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Security" message:@"As a lunch manager, you only have access to the WildcatConnect Web Portal to update breakfast and lunch information." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                         [alertView show];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                         NSInteger verified = [[[PFUser currentUser] objectForKey:@"verified"] integerValue];
                         if (verified == 0) {
                              av = [[UIAlertView alloc]initWithTitle:@"Registration Key" message:@"Please enter your registration key." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Verify", nil];
                              av.alertViewStyle = UIAlertViewStylePlainTextInput;
                              [av setDelegate:self];
                              [av show];
                         } else {
                              AdministrationMainTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainID"];
                              [self.navigationController popToRootViewControllerAnimated:YES];
                              [self.navigationController pushViewController:controller animated:YES];
                         }
                    }
               } else if (error) {
                    [activity stopAnimating];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Error logging in. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
               }
          }];
     }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (actionSheet == av) {
          if (buttonIndex == 0) {
               NSString *choiceText = [actionSheet textFieldAtIndex:0].text;
               if ([choiceText isEqual:[[PFUser currentUser] objectForKey:@"key"]]) {
                    AdministrationMainTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"MainID"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [self.navigationController pushViewController:controller animated:YES];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Welcome to WildcatConnect!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                    [[PFUser currentUser] setObject:[NSNumber numberWithInteger:1] forKey:@"verified"];
                    [[PFUser currentUser] saveInBackground];
               } else {
                    [PFUser logOutInBackground];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Incorrect registration key." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
               }
          }
          [self.view endEditing:YES];
     } else {
          NSString *email = [actionSheet textFieldAtIndex:0].text;
          if ([self validateEmail:email] == true) {
               if (buttonIndex == 1) {
                    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    [activity setBackgroundColor:[UIColor clearColor]];
                    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                    [activity startAnimating];
                    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError * _Nullable error) {
                         [activity stopAnimating];
                         if (error != nil) {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Whoops. An error occurred in attempting to recover this account. Contact Application Support if you need further assistance." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                              [alert show];
                         } else {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[[@"A recovery link has been sent to you at " stringByAppendingString:email] stringByAppendingString:@". Please contact Application Support if you need further assistance."] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                              [alert show];
                         }
                    }];
               }
          } else {
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid e-mail address. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
               [alert show];
          }
     }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     UIViewController *sourceViewController = segue.sourceViewController;
     UIViewController *destinationController = segue.destinationViewController;
     UINavigationController *navigationController = sourceViewController.navigationController;
          // Pop to root view controller (not animated) before pushing
     [navigationController popToRootViewControllerAnimated:NO];
     [navigationController pushViewController:destinationController animated:YES];
}
@end
