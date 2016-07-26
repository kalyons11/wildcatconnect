//
//  ComposeEventViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/16/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "ComposeEventViewController.h"
#import "EventStructure.h"
#import <Parse/Parse.h>

@interface ComposeEventViewController ()

@end

@implementation ComposeEventViewController {
     BOOL hasChanged;
     BOOL keyboardIsShown;
     UIScrollView *scrollView;
     UILabel *titleRemainingLabel;
     UITextView *titleTextView;
     UITextView *locationTextView;
     UIDatePicker *startDatePicker;
     UITextView *messageTextView;
     UILabel *summaryRemainingLabel;
     UIView *separator;
     UIButton *postButton;
     UIAlertView *postAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     hasChanged = false;
     
     UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(goBack:)];
     
     self.navigationItem.leftBarButtonItem = bbtnBack;
     
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
     
     self.navigationItem.title = @"Event";
     self.navigationController.navigationBar.translucent = NO;
     
     UILabel *descriptionLabelC = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     UIFont *font = [UIFont systemFontOfSize:12];
     [descriptionLabelC setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
     descriptionLabelC.text = @"NOTE: All Events will require administrative approval before they appear in the app.";
     descriptionLabelC.lineBreakMode = NSLineBreakByWordWrapping;
     descriptionLabelC.numberOfLines = 0;
     [descriptionLabelC sizeToFit];
     [scrollView addSubview:descriptionLabelC];
     
     UIView *separatorTwo = [[UIView alloc] initWithFrame:CGRectMake(10, descriptionLabelC.frame.origin.y + descriptionLabelC.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separatorTwo.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separatorTwo];
     
     UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, self.view.frame.size.width - 20, 50)];
     titleLabel.text = @"Title";
     [titleLabel setFont:[UIFont systemFontOfSize:16]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     titleRemainingLabel = [[UILabel alloc] init];
     titleRemainingLabel.text = @"60 characters remaining";
     [titleRemainingLabel setFont:[UIFont systemFontOfSize:10]];
     [titleRemainingLabel sizeToFit];
     titleRemainingLabel.frame = CGRectMake((self.view.frame.size.width - titleRemainingLabel.frame.size.width - 10), titleLabel.frame.origin.y, titleRemainingLabel.frame.size.width, 20);
     [scrollView addSubview:titleRemainingLabel];
     
     titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 70)];
     [titleTextView setDelegate:self];
     [titleTextView setFont:[UIFont systemFontOfSize:16]];
     titleTextView.layer.borderWidth = 1.0f;
     titleTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     titleTextView.scrollEnabled = false;
     titleTextView.tag = 0;
     [scrollView addSubview:titleTextView];
     
     UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleTextView.frame.origin.y + titleTextView.frame.size.height + 10, self.view.frame.size.width - 20, 50)];
     locationLabel.text = @"Location";
     [locationLabel setFont:[UIFont systemFontOfSize:16]];
     locationLabel.lineBreakMode = NSLineBreakByWordWrapping;
     locationLabel.numberOfLines = 0;
     [locationLabel sizeToFit];
     [scrollView addSubview:locationLabel];
     
     locationTextView = [[UITextView alloc] initWithFrame:CGRectMake(locationLabel.frame.origin.x, locationLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 110)];
     [locationTextView setDelegate:self];
     [locationTextView setFont:[UIFont systemFontOfSize:16]];
     locationTextView.layer.borderWidth = 1.0f;
     locationTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     locationTextView.scrollEnabled = false;
     locationTextView.tag = 0;
     [scrollView addSubview:locationTextView];
     
     UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, locationTextView.frame.origin.y + locationTextView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     dateLabel.text = @"Event Date and Time";
     [dateLabel setFont:[UIFont systemFontOfSize:16]];
     dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
     dateLabel.numberOfLines = 0;
     [dateLabel sizeToFit];
     [scrollView addSubview:dateLabel];
     
     startDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, dateLabel.frame.origin.y + dateLabel.frame.size.height + 10, self.view.frame.size.width - 10, 120)];
     [startDatePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
     [startDatePicker setMinimumDate:[NSDate date]];
     [scrollView addSubview:startDatePicker];
     
     UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startDatePicker.frame.origin.y + startDatePicker.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     authorLabel.text = @"Message";
     [authorLabel setFont:[UIFont systemFontOfSize:16]];
     authorLabel.lineBreakMode = NSLineBreakByWordWrapping;
     authorLabel.numberOfLines = 0;
     [authorLabel sizeToFit];
     [scrollView addSubview:authorLabel];
     
     UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, authorLabel.frame.origin.y + authorLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     [descriptionLabel setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
     descriptionLabel.text = @"(i.e. event reminders, ticket information, parking, etc.) - NOTE: You can embed links in the event content below and they will appear as hyperlinks in the iOS app. (i.e \"http://www.wildcatconnect.org\")";
     descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
     descriptionLabel.numberOfLines = 0;
     [descriptionLabel sizeToFit];
     [scrollView addSubview:descriptionLabel];
     
     messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(authorLabel.frame.origin.x, descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 10, self.view.frame.size.width - 20, 160)];
     [messageTextView setDelegate:self];
     [messageTextView setFont:[UIFont systemFontOfSize:16]];
     messageTextView.layer.borderWidth = 1.0f;
     messageTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     messageTextView.tag = 1;
     [scrollView addSubview:messageTextView];
     
     summaryRemainingLabel = [[UILabel alloc] init];
     summaryRemainingLabel.text = @"300 characters remaining";
     [summaryRemainingLabel setFont:[UIFont systemFontOfSize:10]];
     [summaryRemainingLabel sizeToFit];
     summaryRemainingLabel.frame = CGRectMake((self.view.frame.size.width - summaryRemainingLabel.frame.size.width - 10), authorLabel.frame.origin.y, summaryRemainingLabel.frame.size.width, 20);
     [scrollView addSubview:summaryRemainingLabel];
     
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, messageTextView.frame.origin.y + messageTextView.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     postButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [postButton setTitle:@"SUBMIT FOR APPROVAL" forState:UIControlStateNormal];
     [postButton sizeToFit];
     [postButton addTarget:self action:@selector(postEvent) forControlEvents:UIControlEventTouchUpInside];
     postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
     [scrollView addSubview:postButton];
     
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

- (void)postEvent {
     if (! [self validateAllFields]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please ensure you have correctly filled out all fields!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alertView show];
     } else {
          postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to submit this event for administrative approval?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
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
               [self postEventMethodWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [activity stopAnimating];
                         NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"];
                         if ([array containsObject:[NSString stringWithFormat:@"%lu", (long)3]]) {
                              NSMutableArray *newArray = [array mutableCopy];
                              [newArray removeObject:[NSString stringWithFormat:@"%lu", (long)3]];
                              [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"visitedPagesArray"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                         }
                         [self.navigationController popViewControllerAnimated:YES];
                    });
               }];
          }
          
     } else {
          if (buttonIndex == 1) {
               [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
          }
     }
}

- (void)postEventMethodWithCompletion:(void (^)(NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     EventStructure *event = [[EventStructure alloc] init];
     event.titleString = titleTextView.text;
     event.locationString = locationTextView.text;
     event.eventDate = startDatePicker.date;
     event.messageString = messageTextView.text;
     NSString *firstName = [[PFUser currentUser] objectForKey:@"firstName"];
     NSString *lastName = [[PFUser currentUser] objectForKey:@"lastName"];
     event.userString = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
     event.email = [[PFUser currentUser] objectForKey:@"email"];
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          event.isApproved = [NSNumber numberWithInteger:1];
     } else {
          event.isApproved = [NSNumber numberWithInteger:0];
     }
     PFQuery *query = [EventStructure query];
     [query orderByDescending:@"ID"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          if (object) {
               event.ID = [NSNumber numberWithInteger:([((EventStructure *)object).ID integerValue] + 1)];
          } else
               event.ID = [NSNumber numberWithInteger:0];
          [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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
     if (textView == titleTextView) {
          int len = textView.text.length;
          if (60 - len <= 10) {
               if (60 - len == 1) {
                    titleRemainingLabel.text= [[NSString stringWithFormat:@"%i",60-len] stringByAppendingString:@" character remaining"];
               } else {
                    
                    titleRemainingLabel.text= [[NSString stringWithFormat:@"%i",60-len] stringByAppendingString:@" characters remaining"];
               }
               titleRemainingLabel.textColor = [UIColor redColor];
               [titleRemainingLabel sizeToFit];
               titleRemainingLabel.frame = CGRectMake((self.view.frame.size.width - titleRemainingLabel.frame.size.width - 10), titleRemainingLabel.frame.origin.y, titleRemainingLabel.frame.size.width, 20);
          } else {
               titleRemainingLabel.text= [[NSString stringWithFormat:@"%i",60-len] stringByAppendingString:@" characters remaining"];
               titleRemainingLabel.textColor = [UIColor blackColor];
               [titleRemainingLabel sizeToFit];
               titleRemainingLabel.frame = CGRectMake((self.view.frame.size.width - titleRemainingLabel.frame.size.width - 10), titleRemainingLabel.frame.origin.y, titleRemainingLabel.frame.size.width, 20);
          }
     } else if (textView == messageTextView) {
          int len = textView.text.length;
          if (300 - len <= 10) {
               if (300 - len == 1) {
                    summaryRemainingLabel.text= [[NSString stringWithFormat:@"%i",300-len] stringByAppendingString:@" character remaining"];
               } else {
                    
                    summaryRemainingLabel.text= [[NSString stringWithFormat:@"%i",300-len] stringByAppendingString:@" characters remaining"];
               }
               summaryRemainingLabel.textColor = [UIColor redColor];
               [summaryRemainingLabel sizeToFit];
               summaryRemainingLabel.frame = CGRectMake((self.view.frame.size.width - summaryRemainingLabel.frame.size.width - 10), summaryRemainingLabel.frame.origin.y, summaryRemainingLabel.frame.size.width, 20);
          } else {
               summaryRemainingLabel.text= [[NSString stringWithFormat:@"%i",300-len] stringByAppendingString:@" characters remaining"];
               summaryRemainingLabel.textColor = [UIColor blackColor];
               [summaryRemainingLabel sizeToFit];
               summaryRemainingLabel.frame = CGRectMake((self.view.frame.size.width - summaryRemainingLabel.frame.size.width - 10), summaryRemainingLabel.frame.origin.y, summaryRemainingLabel.frame.size.width, 20);
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
               return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:60 existsMaximum:YES];
     }
     else if (textView == messageTextView) {
          return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:300 existsMaximum:YES];
     } else if (textView == locationTextView) {
          return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:300 existsMaximum:NO];
     }
     else return nil;
}

- (BOOL)validateAllFields {
     return (titleTextView.text.length > 0 && messageTextView.text.length > 0 && locationTextView.text.length > 0);
}

- (void)dateIsChanged:(id)sender {
     hasChanged = true;
     startDatePicker.minimumDate = [NSDate date];
}

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to this event will be lost."
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
