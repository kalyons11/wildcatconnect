//
//  ComposePollViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/12/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "ComposePollViewController.h"
#import "PollStructure.h"

@interface ComposePollViewController ()

@end

@implementation ComposePollViewController {
     BOOL hasChanged;
     BOOL keyboardIsShown;
     UIScrollView *scrollView;
     UILabel *titleRemainingLabel;
     UITextView *titleTextView;
     UILabel *summaryRemainingLabel;
     UITextView *summaryTextView;
     UITextView *daysTextView;
     UITableView *theTableView;
     UIView *separator;
     UIButton *postButton;
     UIAlertView *av;
     UIAlertView *postAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     self.choicesArray = [[NSMutableArray alloc] init];
     
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
     
     self.navigationItem.title = @"User Poll";
     self.navigationController.navigationBar.translucent = NO;
     
     UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 50)];
     titleLabel.text = @"Poll Title";
     [titleLabel setFont:[UIFont systemFontOfSize:16]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     titleRemainingLabel = [[UILabel alloc] init];
     titleRemainingLabel.text = @"50 characters remaining";
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
     
     UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleTextView.frame.origin.y + titleTextView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     summaryLabel.text = @"Question";
     [summaryLabel setFont:[UIFont systemFontOfSize:16]];
     summaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
     summaryLabel.numberOfLines = 0;
     [summaryLabel sizeToFit];
     [scrollView addSubview:summaryLabel];
     
     summaryRemainingLabel = [[UILabel alloc] init];
     summaryRemainingLabel.text = @"140 characters remaining";
     [summaryRemainingLabel setFont:[UIFont systemFontOfSize:10]];
     [summaryRemainingLabel sizeToFit];
     summaryRemainingLabel.frame = CGRectMake((self.view.frame.size.width - summaryRemainingLabel.frame.size.width - 10), summaryLabel.frame.origin.y, summaryRemainingLabel.frame.size.width, 20);
     [scrollView addSubview:summaryRemainingLabel];
     
     summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(summaryLabel.frame.origin.x, summaryLabel.frame.origin.y + summaryLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     [summaryTextView setDelegate:self];
     [summaryTextView setFont:[UIFont systemFontOfSize:16]];
     summaryTextView.layer.borderWidth = 1.0f;
     summaryTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     summaryTextView.scrollEnabled = false;
     summaryTextView.tag = 3;
     [scrollView addSubview:summaryTextView];
     
     UILabel *daysLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, summaryTextView.frame.origin.y + summaryTextView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     daysLabel.text = @"Days Poll is Active in App";
     [daysLabel setFont:[UIFont systemFontOfSize:16]];
     daysLabel.lineBreakMode = NSLineBreakByWordWrapping;
     daysLabel.numberOfLines = 0;
     [daysLabel sizeToFit];
     [scrollView addSubview:daysLabel];
     
     UILabel *daysInformationLabel = [[UILabel alloc] init];
     daysInformationLabel.text = @"14 days maximum";
     [daysInformationLabel setFont:[UIFont systemFontOfSize:10]];
     [daysInformationLabel sizeToFit];
     daysInformationLabel.frame = CGRectMake((self.view.frame.size.width - daysInformationLabel.frame.size.width - 10), daysLabel.frame.origin.y, daysInformationLabel.frame.size.width, 20);
     [scrollView addSubview:daysInformationLabel];
     
     daysTextView = [[UITextView alloc] initWithFrame:CGRectMake(daysLabel.frame.origin.x, daysLabel.frame.origin.y + daysLabel.frame.size.height + 10, self.view.frame.size.width - 20, 40)];
     [daysTextView setDelegate:self];
     [daysTextView setFont:[UIFont systemFontOfSize:16]];
     daysTextView.layer.borderWidth = 1.0f;
     daysTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     daysTextView.scrollEnabled = false;
     daysTextView.tag = 3;
     [scrollView addSubview:daysTextView];
     
     UILabel *choicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, daysTextView.frame.origin.y + daysTextView.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     choicesLabel.text = @"Choices";
     [choicesLabel setFont:[UIFont systemFontOfSize:16]];
     choicesLabel.lineBreakMode = NSLineBreakByWordWrapping;
     choicesLabel.numberOfLines = 0;
     [choicesLabel sizeToFit];
     [scrollView addSubview:choicesLabel];
     
     UILabel *choiceHelpLabel = [[UILabel alloc] init];
     choiceHelpLabel.text = @"Press the green plus to edit/delete.";
     [choiceHelpLabel setFont:[UIFont systemFontOfSize:10]];
     [choiceHelpLabel sizeToFit];
     choiceHelpLabel.frame = CGRectMake((self.view.frame.size.width - choiceHelpLabel.frame.size.width - 10), choicesLabel.frame.origin.y, choiceHelpLabel.frame.size.width, 20);
     [scrollView addSubview:choiceHelpLabel];
     
     theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, choicesLabel.frame.origin.y + choicesLabel.frame.size.height + 10, self.view.frame.size.width, 300)];
     [theTableView setDelegate:self];
     [theTableView setDataSource:self];
     [theTableView setEditing:YES];
     theTableView.allowsMultipleSelectionDuringEditing = NO;
     [scrollView addSubview:theTableView];
     [theTableView reloadData];
     
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, theTableView.frame.origin.y + theTableView.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     postButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [postButton setTitle:@"POST POLL" forState:UIControlStateNormal];
     [postButton sizeToFit];
     [postButton addTarget:self action:@selector(postPoll) forControlEvents:UIControlEventTouchUpInside];
     postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
     [scrollView addSubview:postButton];
     
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

- (void)postPoll {
     if (! [self validateAllFields]) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please ensure you have correctly filled out all fields!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
          [alertView show];
     } else {
          postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to post this extracurricular update? It will be live to all app users." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [postAlertView show];
     }
}

- (BOOL)validateAllFields {
     return (titleTextView.text.length > 0 && summaryTextView.text.length > 0 && daysTextView.text.length > 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
          // If user deletes
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
               //DELETE THE KEY FROM YOUR DATASOURCE AND THEN:
          [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                           withRowAnimation:UITableViewRowAnimationFade]; //NICE EFFECT
     }
     else if(editingStyle == UITableViewCellEditingStyleInsert)
     {
               //ADD THE KEY TO YOUR DATASOURCE AND THEN:
          if (indexPath.row < self.choicesArray.count) {
               av = [[UIAlertView alloc]initWithTitle:@"Poll Option" message:@"Please enter this poll choice." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", @"Delete", nil];
          } else {
               av = [[UIAlertView alloc]initWithTitle:@"Poll Option" message:@"Please enter this poll choice." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
          }
          av.alertViewStyle = UIAlertViewStylePlainTextInput;
          if (indexPath.row < self.choicesArray.count) {
               [av textFieldAtIndex:0].text = [self.choicesArray objectAtIndex:indexPath.row];
          }
          [av textFieldAtIndex:0].delegate = self;
          av.tag = indexPath.row;
          [av setDelegate:self];
          [av show];
          [tableView reloadData]; //THIS JUST RELOADS THE TABLE WITH YOUR DATASOURCE UPDATED
     }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
     return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     if (indexPath.row < self.choicesArray.count) {
          cell.textLabel.text = [self.choicesArray objectAtIndex:indexPath.row];
          cell.textLabel.numberOfLines = 0;
          cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
     }
     else
          cell.textLabel.text = @"New Choice";
     return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.choicesArray.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to this poll will be lost."
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
     if (textView == titleTextView) {
          int len = textView.text.length;
          if (50 - len <= 10) {
               if (50 - len == 1) {
                    titleRemainingLabel.text= [[NSString stringWithFormat:@"%i",50-len] stringByAppendingString:@" character remaining"];
               } else {
                    
                    titleRemainingLabel.text= [[NSString stringWithFormat:@"%i",50-len] stringByAppendingString:@" characters remaining"];
               }
               titleRemainingLabel.textColor = [UIColor redColor];
               [titleRemainingLabel sizeToFit];
               titleRemainingLabel.frame = CGRectMake((self.view.frame.size.width - titleRemainingLabel.frame.size.width - 10), titleRemainingLabel.frame.origin.y, titleRemainingLabel.frame.size.width, 20);
          } else {
               titleRemainingLabel.text= [[NSString stringWithFormat:@"%i",50-len] stringByAppendingString:@" characters remaining"];
               titleRemainingLabel.textColor = [UIColor blackColor];
               [titleRemainingLabel sizeToFit];
               titleRemainingLabel.frame = CGRectMake((self.view.frame.size.width - titleRemainingLabel.frame.size.width - 10), titleRemainingLabel.frame.origin.y, titleRemainingLabel.frame.size.width, 20);
          }
     } else if (textView == summaryTextView) {
          int len = textView.text.length;
          if (140 - len <= 10) {
               if (140 - len == 1) {
                    summaryRemainingLabel.text= [[NSString stringWithFormat:@"%i",140-len] stringByAppendingString:@" character remaining"];
               } else {
                    
                    summaryRemainingLabel.text= [[NSString stringWithFormat:@"%i",140-len] stringByAppendingString:@" characters remaining"];
               }
               summaryRemainingLabel.textColor = [UIColor redColor];
               [summaryRemainingLabel sizeToFit];
               summaryRemainingLabel.frame = CGRectMake((self.view.frame.size.width - summaryRemainingLabel.frame.size.width - 10), summaryRemainingLabel.frame.origin.y, summaryRemainingLabel.frame.size.width, 20);
          } else {
               summaryRemainingLabel.text= [[NSString stringWithFormat:@"%i",140-len] stringByAppendingString:@" characters remaining"];
               summaryRemainingLabel.textColor = [UIColor blackColor];
               [summaryRemainingLabel sizeToFit];
               summaryRemainingLabel.frame = CGRectMake((self.view.frame.size.width - summaryRemainingLabel.frame.size.width - 10), summaryRemainingLabel.frame.origin.y, summaryRemainingLabel.frame.size.width, 20);
          }
     }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (actionSheet == av) {
          if (buttonIndex == 2) {
               hasChanged = true;
               NSInteger tag = actionSheet.tag;
               [self.choicesArray removeObjectAtIndex:tag];
               [theTableView reloadData];
          }
          else if (buttonIndex == 1) {
               hasChanged = true;
               NSString *choiceText = [actionSheet textFieldAtIndex:0].text;
               choiceText = [[choiceText stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""];
               if (! [choiceText isEqualToString:@""]) {
                    NSInteger tag = actionSheet.tag;
                    if (tag == self.choicesArray.count) {
                         if (self.choicesArray.count == 0) {
                              self.choicesArray = [NSMutableArray arrayWithObjects:choiceText, nil];
                         } else
                              [self.choicesArray addObject:choiceText];
                    } else {
                         [self.choicesArray setObject:choiceText atIndexedSubscript:tag];
                    }
                    [theTableView reloadData];
               }
          }
          [self.view endEditing:YES];
     } else if (actionSheet == postAlertView) {
          if (buttonIndex == 1) {
               UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, postButton.frame.origin.y, 30, 30)];
               [postButton removeFromSuperview];
               [activity setBackgroundColor:[UIColor clearColor]];
               [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
               [scrollView addSubview:activity];
               [activity startAnimating];
               [self postPollMethodWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [activity stopAnimating];
                         NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"];
                         if ([array containsObject:[NSString stringWithFormat:@"%lu", (long)4]]) {
                              NSMutableArray *newArray = [array mutableCopy];
                              [newArray removeObject:[NSString stringWithFormat:@"%lu", (long)4]];
                              [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"visitedPagesArray"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                         }
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

- (void)postPollMethodWithCompletion:(void (^)(NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PollStructure *pollStructure = [[PollStructure alloc] init];
     pollStructure.pollTitle = titleTextView.text;
     pollStructure.pollQuestion = summaryTextView.text;
     pollStructure.totalResponses = @"0";
     pollStructure.daysActive = [NSNumber numberWithInteger:[daysTextView.text integerValue]];
     pollStructure.isActive = [NSNumber numberWithInteger:1];
     NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
     for (NSString *choice in self.choicesArray) {
          [dictionary setObject:@"0" forKey:choice];
     }
     pollStructure.pollMultipleChoices = dictionary;
     PFQuery *query = [PollStructure query];
     [query orderByDescending:@"pollID"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          PollStructure *structure = (PollStructure *)object;
          if (! structure) {
               pollStructure.pollID = [[NSNumber numberWithInt:0] stringValue];
          } else
               pollStructure.pollID = [[NSNumber numberWithInt:([structure.pollID integerValue] + 1)] stringValue];
          [pollStructure saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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
               return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:50 existsMaximum:YES];
     }
     else if (textView == summaryTextView) {
          if([string isEqualToString:@"\n"])
          {
               [textView resignFirstResponder];
               
               return NO;
          } else
               return [self isAcceptableTextLength:textView.text.length + string.length - range.length forMaximum:140 existsMaximum:YES];
     } else if (textView == daysTextView) {
          NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
          if ([string rangeOfCharacterFromSet:notDigits].location == NSNotFound)
          {
               if ([[daysTextView.text stringByAppendingString:string] integerValue] > 14 || [[daysTextView.text stringByAppendingString:string] integerValue] == 0) {
                    return NO;
               } else return YES;
          } else return NO;
     }
     else return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
