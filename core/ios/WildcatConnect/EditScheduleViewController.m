//
//  EditScheduleViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/17/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "EditScheduleViewController.h"
#import "SchoolDayStructure.h"
#import "CustomScheduleViewController.h"
#import "SpecialKeyStructure.h"

@interface EditScheduleViewController ()

@end

@implementation EditScheduleViewController {
     BOOL hasChanged;
     BOOL keyboardIsShown;
     UIScrollView *scrollView;
     UILabel *titleLabel;
     UIActivityIndicatorView *activity;
     UITableView *theTableView;
     UIAlertView *errorAlertView;
     UIActionSheet *popupActionSheet;
     BOOL reload;
     UILabel *modeLabel;
     UIView *separator;
     UIButton *modeButton;
}

@synthesize modeString;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     self.navigationItem.title = @"Scheduling";
     self.navigationController.navigationBar.translucent = NO;
     
     hasChanged = false;
     reload = false;
     
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
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     titleLabel.text = @"Tap on a day to edit its schedule with the following options...\n\n- Go back a day\n\n- Edit a custom schedule";
     [titleLabel setFont:[UIFont systemFontOfSize:16]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     modeButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [modeButton setTitle:@"EDIT SCHEDULE MODE FOR VACATIONS" forState:UIControlStateNormal];
     [modeButton sizeToFit];
     [modeButton addTarget:self action:@selector(modeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
     modeButton.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, modeButton.frame.size.width, modeButton.frame.size.height);
     [scrollView addSubview:modeButton];
     
     modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, modeButton.frame.origin.y + modeButton.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     modeLabel.text = @"Current Mode - LOADING...";
     [modeLabel setFont:[UIFont systemFontOfSize:16]];
     modeLabel.lineBreakMode = NSLineBreakByWordWrapping;
     modeLabel.numberOfLines = 0;
     [modeLabel sizeToFit];
     [scrollView addSubview:modeLabel];
     
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, modeLabel.frame.origin.y + modeLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width, 250)];
     [theTableView setDelegate:self];
     [theTableView setDataSource:self];
     [scrollView addSubview:theTableView];
     [theTableView reloadData];
     
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     [self reloadMethodBig];
     
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

- (void)reloadMethodBig {
     [self getModeMethodWithCompletion:^(NSString *returnString, NSError *error) {
          
          [self getModeMethodWithCompletion:^(NSString *returnString, NSError *error) {
               
               self.modeString = returnString;
               
               [self getSchedulesMethodWithCompletion:^(NSMutableArray *returnArray, NSError *error) {
                    
                    [activity stopAnimating];
                    
                    self.scheduleArray = returnArray;
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [self reloadMethod];
                    });
               }];
          }];
          
     }];
}

- (void)reloadMethod {
     
     [modeLabel removeFromSuperview];
     modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, modeButton.frame.origin.y + modeButton.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     [modeLabel setFont:[UIFont systemFontOfSize:16]];
     modeLabel.lineBreakMode = NSLineBreakByWordWrapping;
     modeLabel.numberOfLines = 0;
     [scrollView addSubview:modeLabel];
     [modeLabel setText:[@"Current Mode - " stringByAppendingString:self.modeString]];
     [modeLabel sizeToFit];
     
     [separator removeFromSuperview];
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, modeLabel.frame.origin.y + modeLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     [theTableView removeFromSuperview];
     theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width, 250)];
     [theTableView setDelegate:self];
     [theTableView setDataSource:self];
     [scrollView addSubview:theTableView];
     
     [theTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     
     if (reload == true) {
          
          reload = false;
          
          self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                                 green:183.0f/255.0f
                                                                                  blue:23.0f/255.0f
                                                                                 alpha:0.5f];
          
          self.navigationItem.title = @"Scheduling";
          self.navigationController.navigationBar.translucent = NO;
          
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
          
          [scrollView removeFromSuperview];
          scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
          scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
          
          titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
          titleLabel.text = @"Tap on a day to edit its schedule with the following options...\n\n- Go back a day\n\n- Edit a custom schedule";
          [titleLabel setFont:[UIFont systemFontOfSize:16]];
          titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
          titleLabel.numberOfLines = 0;
          [titleLabel sizeToFit];
          [scrollView addSubview:titleLabel];
          
          modeButton = [UIButton buttonWithType:UIButtonTypeSystem];
          [modeButton setTitle:@"EDIT SCHEDULE MODE FOR VACATIONS" forState:UIControlStateNormal];
          [modeButton sizeToFit];
          [modeButton addTarget:self action:@selector(modeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
          modeButton.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, modeButton.frame.size.width, modeButton.frame.size.height);
          [scrollView addSubview:modeButton];
          
          modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, modeButton.frame.origin.y + modeButton.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
          modeLabel.text = @"Current Mode - LOADING...";
          [modeLabel setFont:[UIFont systemFontOfSize:16]];
          modeLabel.lineBreakMode = NSLineBreakByWordWrapping;
          modeLabel.numberOfLines = 0;
          [modeLabel sizeToFit];
          [scrollView addSubview:modeLabel];
          
          separator = [[UIView alloc] initWithFrame:CGRectMake(10, modeLabel.frame.origin.y + modeLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
          separator.backgroundColor = [UIColor blackColor];
          [scrollView addSubview:separator];
          
          theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width, 250)];
          [theTableView setDelegate:self];
          [theTableView setDataSource:self];
          [scrollView addSubview:theTableView];
          [theTableView reloadData];
          
          activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          
          [self reloadMethodBig];
          
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
}

- (void)modeButtonClicked {
     popupActionSheet = [[UIActionSheet alloc] initWithTitle:@"Schedule Modes" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                         @"NORMAL",
                             @"THANKSGIVING BREAK",
                             @"HOLIDAY BREAK",
                             @"FEBRUARY BREAK",
                             @"SPRING BREAK",
                             @"SUMMER",
                             nil];
     [popupActionSheet showInView:self.view];
}

- (void)getSchedulesMethodWithCompletion:(void (^)(NSMutableArray *returnArray, NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *returnArray = [NSMutableArray array];
     PFQuery *query = [SchoolDayStructure query];
     query.limit = 10;
     [query whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];
     [query orderByAscending:@"schoolDayID"];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          [returnArray addObjectsFromArray:objects];
          if (error != nil) {
               theError = error;
          }
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil && returnArray.count == 0) {
               overallError = theError;
          }
          completion(returnArray, overallError);
     });
}

- (void)getModeMethodWithCompletion:(void (^)(NSString *returnString, NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     __block NSString *returnString;
     PFQuery *query = [SpecialKeyStructure query];
     [query whereKey:@"key" equalTo:@"scheduleMode"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          returnString = [object objectForKey:@"value"];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil && returnString.length == 0) {
               overallError = theError;
          }
          completion(returnString, overallError);
     });
}

- (void)saveModeMethodWithCompletion:(void (^)(NSError *error))completion forString:(NSString *)theString {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [SpecialKeyStructure query];
     [query whereKey:@"key" equalTo:@"scheduleMode"];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          theError = error;
          [object setObject:theString forKey:@"value"];
          [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               theError = error;
               dispatch_group_leave(serviceGroup);
          }];
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(overallError);
     });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     
     if (self.scheduleArray.count == 0) {
          cell.textLabel.text = @"Loading...";
     } else {
          NSDateFormatter *day = [[NSDateFormatter alloc] init];
          [day setDateFormat:@"EEEE"];
          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
          [dateFormatter setDateFormat:@"MM-dd-yyyy"];
          SchoolDayStructure *schoolDay = (SchoolDayStructure *)[self.scheduleArray objectAtIndex:indexPath.row];
          NSString *today = [day stringFromDate:[dateFormatter dateFromString:schoolDay.schoolDate]];
          NSString *totalString = [[today stringByAppendingString:@", "] stringByAppendingString:schoolDay.schoolDate];
          cell.textLabel.text = totalString;
          if (indexPath.row == 0)
               cell.textLabel.textColor = [UIColor redColor];
          if ([schoolDay.scheduleType isEqual:@"*"]) {
               cell.detailTextLabel.text = @"Custom Schedule";
               cell.detailTextLabel.textColor = [UIColor redColor];
          } else
               cell.detailTextLabel.text = schoolDay.scheduleType;
}
     
     return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Scheduling Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                             @"Go Back 1 Day from Here",
                             @"Edit Custom Schedule",
                             nil];
     [popup setTag:[[[self.scheduleArray objectAtIndex:indexPath.row] objectForKey:@"schoolDayID"] integerValue]];
     [popup showInView:self.view]; 
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
     if (popup == popupActionSheet) {
               //Need to develop SpecialKeyStructure
               //Will have a "key" and "value" parameter, both strings???
               //For instance, one will be { key : "scheduleMode" , value : "NORMAL" }
               //Another will need to be { key : "doSDSD" , value : "1" }
               //the afterSave trigger for this structure will need to take a look at the key paramter
               //if it is "scheduleMode", then other keys must be reflected... (i.e. turning off/on all necessary Cloud Code functions...
          
               //Set the SKS for "scheduleMode" to a given string
          
          NSString *theString;
          
          switch (buttonIndex) {
               case 0:
                    theString = @"NORMAL";
                    break;
               
               case 1:
                    theString = @"THANKSGIVING BREAK";
                    break;
               
               case 2:
                    theString = @"HOLIDAY BREAK";
                    break;
                    
               case 3:
                    theString = @"FEBRUARY BREAK";
                    break;
                    
               case 4:
                    theString = @"SPRING BREAK";
                    break;
                    
               case 5:
                    theString = @"SUMMER";
                    break;
                    
               default:
                    break;
          }
          
          [self saveModeMethodWithCompletion:^(NSError *error) {
               
          } forString:theString];
          
     } else {
          if (buttonIndex == 0) {
                    //Go Back 1 Day
               if (popup.tag != [[[self.scheduleArray objectAtIndex:self.scheduleArray.count - 1] objectForKey:@"schoolDayID"] integerValue]) {
                    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    [activity setBackgroundColor:[UIColor clearColor]];
                    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
                    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                    [activity startAnimating];
                    [PFCloud callFunctionInBackground:@"goBackOneDayFromStructure" withParameters:@{@"ID":[NSNumber numberWithInteger:popup.tag]} block:^(id  _Nullable object, NSError * _Nullable error) {
                         [activity stopAnimating];
                         [self reloadMethodBig];
                    }];
               } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You can't go back a day from here." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
               }
          } else if (buttonIndex == 1) {
                    //Edit Custom Schedule
               CustomScheduleViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CustomSchedule"];
               NSDateFormatter *day = [[NSDateFormatter alloc] init];
               [day setDateFormat:@"EEEE"];
               NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
               [dateFormatter setDateFormat:@"MM-dd-yyyy"];
               SchoolDayStructure *schoolDay = (SchoolDayStructure *)[self.scheduleArray objectAtIndex:popup.tag];
               NSString *today = [day stringFromDate:[dateFormatter dateFromString:schoolDay.schoolDate]];
               NSString *totalString = [[today stringByAppendingString:@", "] stringByAppendingString:schoolDay.schoolDate];
               controller.titleString = totalString;
               controller.IDString = schoolDay.schoolDayID;
               if ([schoolDay.scheduleType isEqual:@"*"]) {
                    controller.scheduleString = schoolDay.customSchedule;
               } else {
                    controller.scheduleString = @"Period 1: \nPeriod 2: \nPeriod 3: \nPeriod 4: \n1st: \n2nd: \n3rd: \nPeriod 6: \nPeriod 7: ";
               }
               [self.navigationController pushViewController:controller animated:YES];
          }
     }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (self.scheduleArray.count == 0) {
          return 1;
     } else
          return self.scheduleArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 80;
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

- (void)goBack:(UIBarButtonItem *)sender
{
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to this scheduling will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
     else {
          [self.navigationController popViewControllerAnimated:YES];
     }
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
