//
//  ComposeCommunityServiceViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/16/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "ComposeCommunityServiceViewController.h"
#import "CommunityServiceStructure.h"

@interface ComposeCommunityServiceViewController ()

@end

@implementation ComposeCommunityServiceViewController {
     UIScrollView *scrollView;
     UILabel *titleRemainingLabel;
     UITextView *titleTextView;
     UIDatePicker *startDatePicker;
     UIDatePicker *endDatePicker;
     UITextView *authorTextView;
     UILabel *summaryRemainingLabel;
     BOOL hasChanged;
     UIView *separator;
     UIButton *postButton;
     UIAlertView *postAlertView;
     BOOL keyboardIsShown;
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
     
     self.navigationItem.title = @"Community Service";
     self.navigationController.navigationBar.translucent = NO;
     
     UILabel *descriptionLabelC = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     UIFont *font = [UIFont systemFontOfSize:12];
     [descriptionLabelC setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
     descriptionLabelC.text = @"NOTE: All community service opportunities will require administrative approval before they appear in the app.";
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
     
     UILabel *descriptionLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, titleTextView.frame.origin.y + titleTextView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     [descriptionLabelB setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
     descriptionLabelB.text = @"NOTE: If you are unsure of the exact start or end time for this opportunity, please leave adequate time in the dates below.";
     descriptionLabelB.lineBreakMode = NSLineBreakByWordWrapping;
     descriptionLabelB.numberOfLines = 0;
     [descriptionLabelB sizeToFit];
     [scrollView addSubview:descriptionLabelB];
     
     UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, descriptionLabelB.frame.origin.y + descriptionLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     dateLabel.text = @"Start Date";
     [dateLabel setFont:[UIFont systemFontOfSize:16]];
     dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
     dateLabel.numberOfLines = 0;
     [dateLabel sizeToFit];
     [scrollView addSubview:dateLabel];
     
     startDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, dateLabel.frame.origin.y + dateLabel.frame.size.height + 10, self.view.frame.size.width - 10, 120)];
     [startDatePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
     [scrollView addSubview:startDatePicker];
     
     UILabel *endDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, startDatePicker.frame.origin.y + startDatePicker.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     endDateLabel.text = @"End Date";
     [endDateLabel setFont:[UIFont systemFontOfSize:16]];
     endDateLabel.lineBreakMode = NSLineBreakByWordWrapping;
     endDateLabel.numberOfLines = 0;
     [endDateLabel sizeToFit];
     [scrollView addSubview:endDateLabel];
     
     endDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, endDateLabel.frame.origin.y + endDateLabel.frame.size.height + 10, self.view.frame.size.width - 10, 120)];
     [endDatePicker addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
     [endDatePicker setMinimumDate:startDatePicker.date];
     [scrollView addSubview:endDatePicker];
     
     UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, endDatePicker.frame.origin.y + endDatePicker.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     authorLabel.text = @"Message";
     [authorLabel setFont:[UIFont systemFontOfSize:16]];
     authorLabel.lineBreakMode = NSLineBreakByWordWrapping;
     authorLabel.numberOfLines = 0;
     [authorLabel sizeToFit];
     [scrollView addSubview:authorLabel];
     
     authorTextView = [[UITextView alloc] initWithFrame:CGRectMake(authorLabel.frame.origin.x, authorLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 160)];
     [authorTextView setDelegate:self];
     [authorTextView setFont:[UIFont systemFontOfSize:16]];
     authorTextView.layer.borderWidth = 1.0f;
     authorTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     authorTextView.tag = 1;
     [scrollView addSubview:authorTextView];
     
     summaryRemainingLabel = [[UILabel alloc] init];
     summaryRemainingLabel.text = @"300 characters remaining";
     [summaryRemainingLabel setFont:[UIFont systemFontOfSize:10]];
     [summaryRemainingLabel sizeToFit];
     summaryRemainingLabel.frame = CGRectMake((self.view.frame.size.width - summaryRemainingLabel.frame.size.width - 10), authorLabel.frame.origin.y, summaryRemainingLabel.frame.size.width, 20);
     [scrollView addSubview:summaryRemainingLabel];
     
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, authorTextView.frame.origin.y + authorTextView.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     postButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [postButton setTitle:@"SUBMIT FOR APPROVAL" forState:UIControlStateNormal];
     [postButton sizeToFit];
     [postButton addTarget:self action:@selector(postUpdate) forControlEvents:UIControlEventTouchUpInside];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dateIsChanged:(id)sender {
     hasChanged = true;
     if ((UIDatePicker *)(sender) == startDatePicker) {
          endDatePicker.minimumDate = startDatePicker.date;
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

- (void)postUpdate {
     if (! [self validateAllFields]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please ensure you have correctly filled out all fields!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alertView show];
     } else {
          postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to submit this community service opportunity for administrative approval?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [postAlertView show];
     }
}

- (void)postUpdateMethodWithCompletion:(void (^)(NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     CommunityServiceStructure *communityServiceStructure = [[CommunityServiceStructure alloc] init];
     communityServiceStructure.commTitleString = titleTextView.text;
     communityServiceStructure.commSummaryString = authorTextView.text;
     communityServiceStructure.startDate = startDatePicker.date;
     communityServiceStructure.endDate = endDatePicker.date;
     NSString *firstName = [[PFUser currentUser] objectForKey:@"firstName"];
     NSString *lastName = [[PFUser currentUser] objectForKey:@"lastName"];
     communityServiceStructure.userString = [[firstName stringByAppendingString:@" "] stringByAppendingString:lastName];
     communityServiceStructure.email = [[PFUser currentUser] objectForKey:@"email"];
     if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
          communityServiceStructure.isApproved = [NSNumber numberWithInteger:1];
     } else {
          communityServiceStructure.isApproved = [NSNumber numberWithInteger:0];
     }
     PFQuery *query = [CommunityServiceStructure query];
     [query orderByDescending:@"communityServiceID"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          if (error) {
               communityServiceStructure.communityServiceID = [NSNumber numberWithInt:0];
               [communityServiceStructure saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error) {
                         theError = error;
                    }
                    dispatch_group_leave(serviceGroup);
               }];
          } else {
               CommunityServiceStructure *structure = (CommunityServiceStructure *)object;
               if (structure) {
                    communityServiceStructure.communityServiceID = [NSNumber numberWithInteger:[structure.communityServiceID integerValue] + 1];
               } else {
                    communityServiceStructure.communityServiceID = [NSNumber numberWithInteger:0];
               }
               [communityServiceStructure saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error) {
                         theError = error;
                    }
                    dispatch_group_leave(serviceGroup);
               }];
          }
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(theError);
     });
}

- (BOOL)validateAllFields {
     return (titleTextView.text.length > 0 && authorTextView.text.length > 0);
}

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to this community service update will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
     else {
          [self.navigationController popViewControllerAnimated:YES];
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
                         if ([array containsObject:[NSString stringWithFormat:@"%lu", (long)0]]) {
                              NSMutableArray *newArray = [array mutableCopy];
                              [newArray removeObject:[NSString stringWithFormat:@"%lu", (long)0]];
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
     } else if (textView == authorTextView) {
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
     else if (textView == authorTextView) {
          return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:300 existsMaximum:YES];
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
