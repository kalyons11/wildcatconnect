//
//  ExtracurricularsTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/17/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "ExtracurricularsTableViewController.h"
#import "ExtracurricularStructure.h"
#import "ExtracurricularUpdateStructure.h"
#import "AppManager.h"
#import "GroupMainTableViewController.h"
#import "ECUDetailViewController.h"

@interface ExtracurricularsTableViewController ()

@end

@implementation ExtracurricularsTableViewController {
     UIActivityIndicatorView *activity;
     UIAlertView *unsubscribeAlertView;
     UIAlertView *subscribeAlertView;
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     
     if (self.loadNumber == [NSNumber numberWithInt:1] || ! self.loadNumber) {
          [self refreshData];
     } else {
          activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          [self getOldUpdatesWithCompletion:^(NSMutableArray *returnArray) {
               self.updatesArray = returnArray;
               [self getOldUpdatesTwoWithCompletion:^(NSMutableArray *returnArrayB) {
                    self.extracurricularsArray = returnArrayB;
                    [self getOldImagesWithCompletion:^(NSMutableArray *returnArrayC) {
                         self.ECImagesArray = returnArrayC;
                         dispatch_async(dispatch_get_main_queue(), ^ {
                              [activity stopAnimating];
                              [self.tableView reloadData];
                              [self refreshControl];
                         });
                    }];
               }];
          }];
     }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
    
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
     refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"PULL TO REFRESH"];
    self.refreshControl= refreshControl;
    
     self.navigationItem.title = @"Groups";
}

-(void)refreshView:(UIRefreshControl *)refresh {
     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
     
          // custom refresh logic would be placed here...
     
     [self refreshData];
     
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"MMMM dd, h:mm a"];
     NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                              [formatter stringFromDate:[NSDate date]]];
     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
     [refresh endRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated {
     [super viewWillDisappear:animated];
     NSNumber *count = [NSNumber numberWithInteger:self.updatesArray.count];
     [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"ECviewed"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshData {
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     [self testMethodWithCompletion:^(NSError *error, NSMutableArray *returnArray) {
          if (error) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
                    [self refreshControl];
                    [self.refreshControl endRefreshing];
               });
          } else {
               self.updatesArray = returnArray;
               NSMutableArray *itemsToSave = [NSMutableArray array];
               for (ExtracurricularUpdateStructure *e in returnArray) {
                    [itemsToSave addObject:@{ @"extracurricularID"     : e.extracurricularID,
                                              @"messageString"    : e.messageString,
                                              @"extracurricularUpdateID" :e.extracurricularUpdateID,
                                              @"postDate" : e.postDate
                                              }];
               }
               NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
               [userDefaults setObject:itemsToSave forKey:@"ECUpdates"];
               [self testMethodTwoWithCompletion:^(NSError *error, NSMutableArray *returnArrayA) {
                    [self resortToBottomMethod:^(NSMutableArray *returnArrayNew) {
                         self.extracurricularsArray = returnArrayNew;
                         NSMutableArray *moreItems = [NSMutableArray array];
                         for (ExtracurricularStructure *e in returnArrayNew) {
                              [moreItems addObject:@{ @"titleString"     : e.titleString,
                                                      @"descriptionString"    : e.descriptionString,
                                                      @"hasImage" :e.hasImage,
                                                      @"extracurricularID" : e.extracurricularID
                                                      }];
                         }
                         [userDefaults setObject:moreItems forKey:@"ECArray"];
                         [userDefaults synchronize];
                         dispatch_async(dispatch_get_main_queue(), ^ {
                              [activity stopAnimating];
                              [self.tableView reloadData];
                              [self refreshControl];
                              [self.refreshControl endRefreshing];
                         });
                    } withArray:returnArrayA];
               }];
          }
     }];
}

- (void)resortToBottomMethod:(void (^)(NSMutableArray *returnArray))completion withArray:(NSMutableArray *)array {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     NSMutableArray *theArrayToSort = [array mutableCopy];
     __block ExtracurricularStructure *EC;
     __block NSMutableArray *addArray;
          NSDate *today = [NSDate date];
          NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
               //[myFormatter setDateFormat:@"EEEE"]; // day, like "Saturday"
          [myFormatter setDateFormat:@"c"]; // day number, like 7 for saturday
          NSString *dayOfWeek = [myFormatter stringFromDate:today];
          NSInteger currentDay = [dayOfWeek integerValue] - 2;
          addArray = [[NSMutableArray alloc] init];
          for (int i = 0; i < theArrayToSort.count; i++) {
               EC = (ExtracurricularStructure *)theArrayToSort[i];
               if (EC.meetingIDs.length > 1) {
                    BOOL remove = true;
                    for (int k = 0; k < EC.meetingIDs.length; k++) {
                         if ([[EC.meetingIDs substringWithRange:NSMakeRange(k, 1)] integerValue] >= currentDay) {
                              remove = false;
                         }
                    }
                    if (remove) {
                         [theArrayToSort removeObject:EC];
                         i--;
                         [addArray addObject:EC];
                         
                    }
               } else {
                    if ([EC.meetingIDs integerValue] < currentDay) {
                         [theArrayToSort removeObject:EC];
                         i--;
                         [addArray addObject:EC];
                    }
               }
               if (i == theArrayToSort.count - 1) {
                    dispatch_group_leave(serviceGroup);
               }
          }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSMutableArray *finalArray = [theArrayToSort arrayByAddingObjectsFromArray:addArray];
          completion(finalArray);
     });
}

- (void)getOldUpdatesTwoWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     ExtracurricularStructure *ECStructure;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"ECArray"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i++) {
          object = theArrayToSearch[i];
          ECStructure = [[ExtracurricularStructure alloc] init];
          ECStructure.titleString = [object objectForKey:@"titleString"];
          ECStructure.descriptionString = [object objectForKey:@"descriptionString"];
          ECStructure.hasImage = [object objectForKey:@"hasImage"];
          ECStructure.extracurricularID = [object objectForKey:@"extracurricularID"];
          [array addObject:ECStructure];
          if (i == theArrayToSearch.count - 1)
               dispatch_group_leave(serviceGroup);
     }
     if (theArrayToSearch.count == 0) {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(array);
     });
}

- (void)getOldImagesWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"ECImagesArray"];
     NSData *data;
     UIImage *image;
     for (int i = 0; i < theArrayToSearch.count; i++) {
          data = theArrayToSearch[i];
          image = [UIImage imageWithData:data];
          if (image)
               [array addObject:image];
          else
               [array addObject:[[NSObject alloc] init]];
          if (i == theArrayToSearch.count - 1) {
               dispatch_group_leave(serviceGroup);
          }
     }
     if (theArrayToSearch.count == 0) {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(array);
     });
}

- (void)getOldUpdatesWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     ExtracurricularUpdateStructure *ECUpdateStructure;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"ECUpdates"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i++) {
          object = theArrayToSearch[i];
          ECUpdateStructure = [[ExtracurricularUpdateStructure alloc] init];
          ECUpdateStructure.extracurricularID = [object objectForKey:@"extracurricularID"];
          ECUpdateStructure.messageString = [object objectForKey:@"messageString"];
          ECUpdateStructure.extracurricularUpdateID = [object objectForKey:@"extracurricularUpdateID"];
          ECUpdateStructure.postDate = [object objectForKey:@"postDate"];
          [array addObject:ECUpdateStructure];
          if (i == theArrayToSearch.count - 1)
               dispatch_group_leave(serviceGroup);
     }
     if (theArrayToSearch.count == 0) {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(array);
     });
}

- (void)testMethodFourWithCompletion:(void (^)(NSError *error, NSData *data))completion withFile:(PFFile *)file {
     __block NSError *theError = nil;
     __block NSData *theData;
     dispatch_group_t theServiceGroup = dispatch_group_create();
     dispatch_group_enter(theServiceGroup);
     [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
          theData = data;
          theError = error;
          dispatch_group_leave(theServiceGroup);
     }];
     dispatch_group_notify(theServiceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError)
               overallError = theError;
          completion(theError, theData);
     });
}

//- (void)testMethodThreeWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion withArray:(NSMutableArray *)array {
//     __block NSError *theError = nil;
//     __block BOOL lastNone = false;
//     dispatch_group_t theServiceGroup = dispatch_group_create();
//     dispatch_group_enter(theServiceGroup);
//     NSMutableArray *theReturnArray = [NSMutableArray arrayWithArray:array];
//     ExtracurricularStructure *ECStructure;
//     for (int i = 0; i < array.count; i++) {
//          ECStructure = (ExtracurricularStructure *)[array objectAtIndex:i];
//          NSInteger imageNumber = [ECStructure.hasImage integerValue];
//          if (imageNumber == 1) {
//               PFFile *file = ECStructure.imageFile;
//               [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                    UIImage *image = [UIImage imageWithData:data];
//                    image = [[AppManager getInstance] imageFromImage:image scaledToWidth:70];
//                    [theReturnArray setObject:image atIndexedSubscript:[[NSNumber numberWithInt:i] integerValue]];
//                         BOOL go = true;
//                         for (NSObject *object in theReturnArray) {
//                              if (object.class == [ExtracurricularStructure class]) {
//                                   go = false;
//                                   break;
//                              }
//                         }
//                         if (go) {
//                              dispatch_group_leave(theServiceGroup);
//                         }
//               }];
//          } else {
//               [theReturnArray setObject:[[NSObject alloc] init] atIndexedSubscript:[[NSNumber numberWithInt:i] integerValue]];
//               if (i == array.count - 1) {
//                    BOOL go = true;
//                    for (NSObject *object in theReturnArray) {
//                         if (object.class == [ExtracurricularStructure class]) {
//                              go = false;
//                              break;
//                         }
//                    }
//                    if (go) {
//                         dispatch_group_leave(theServiceGroup);
//                    }
//               }
//          }
//     }
//     if (array.count == 0) {
//          dispatch_group_leave(theServiceGroup);
//     }
//     dispatch_group_notify(theServiceGroup, dispatch_get_main_queue(), ^{
//          NSError *overallError = nil;
//          if (theError)
//               overallError = theError;
//          completion(overallError, theReturnArray);
//     });
//}

- (void)testMethodTwoWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
     __block NSError *theError = nil;
     dispatch_group_t theServiceGroup = dispatch_group_create();
     dispatch_group_enter(theServiceGroup);
     NSMutableArray *theReturnArray = [[NSMutableArray alloc] init];
     PFQuery *query = [ExtracurricularStructure query];
     [query orderByAscending:@"titleString"];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          [theReturnArray addObjectsFromArray:objects];
          theError = error;
          [[PFInstallation currentInstallation] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable errorTwo) {
                    theError = errorTwo;
               dispatch_group_leave(theServiceGroup);
          }];
     }];
     dispatch_group_notify(theServiceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError)
               overallError = theError;
          completion(overallError, theReturnArray);
     });
}

- (void)testMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
     __block NSError *theError = nil;
     dispatch_group_t theServiceGroup = dispatch_group_create();
     dispatch_group_enter(theServiceGroup);
     NSMutableArray *returnArray = [[NSMutableArray alloc] init];
          //Return array will be updatesArray
     NSMutableArray *myArray = [[[PFInstallation currentInstallation] objectForKey:@"channels"] mutableCopy];
     for (int i = 0; i < myArray.count; i++) {
          if ([myArray[i] length] >= 2) {
               myArray[i] = [NSNumber numberWithInteger:[((NSString *)[myArray[i] substringFromIndex:1]) integerValue]];
          }
     }
     PFQuery *query = [ExtracurricularUpdateStructure query];
     [query whereKey:@"extracurricularID" containedIn:myArray];
     [query orderByDescending:@"createdAt"];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          [returnArray addObjectsFromArray:objects];
          theError = error;
          dispatch_group_leave(theServiceGroup);
     }];
     dispatch_group_notify(theServiceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError)
               overallError = theError;
          completion(overallError, returnArray);
     });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber {
     self = [super init];
     self.loadNumber = theLoadNumber;
     self.navigationItem.title = @"Extracurriculars";
     return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
     if (section == 0) {
          if (self.updatesArray.count == 0) {
               return 1;
          } else
               return self.updatesArray.count;
     } else if (section == 1) {
          return 1;
     }
     else return nil;
}


/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
          // Configure the cell...
     
    return cell;
}*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     if (section == 0)
          return @"MY UPDATES";
     else if (section == 1)
          return @"ALL GROUPS";
     else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     if (indexPath.section == 0) {
          if (self.updatesArray.count == 0) {
               UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
               cell.textLabel.text = @"No updates to display.";
               return  cell;
          } else {
               ExtracurricularUpdateStructure *extracurricularUpdateStructure = ((ExtracurricularUpdateStructure *)[self.updatesArray objectAtIndex:indexPath.row]);
               ExtracurricularStructure *EC = [extracurricularUpdateStructure getStructureForUpdate:extracurricularUpdateStructure withArray:[self.extracurricularsArray copy]];
               UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
               cell.textLabel.text = EC.titleString;
               cell.detailTextLabel.text = extracurricularUpdateStructure.messageString;
               cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
               return cell;
          }
     } else if (indexPath.section == 1) {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
          cell.textLabel.text = @"View All Groups";
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
          return cell;
     }
     else return nil;
}

- (void)addGroup:(id)sender {
     NSInteger index = ((UIButton *)sender).tag;
     ExtracurricularStructure *EC = [self.extracurricularsArray objectAtIndex:index];
     subscribeAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[[@"Are you sure you want to subscribe to the group \"" stringByAppendingString:EC.titleString] stringByAppendingString:@"\"?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Subscribe", nil];
     subscribeAlertView.tag = index;
     [subscribeAlertView show];
}

- (void)removeGroup:(id)sender {
     NSInteger index = ((UIButton *)sender).tag;
     ExtracurricularStructure *EC = [self.extracurricularsArray objectAtIndex:[self getIndexofStructureWithID:[[self.updatesArray objectAtIndex:index] objectForKey:@"extracurricularID"]]];
    unsubscribeAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[[@"Are you sure you want to unsubscribe from the group \"" stringByAppendingString:EC.titleString] stringByAppendingString:@"\"?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Unsubscribe", nil];
     unsubscribeAlertView.tag = index;
     [unsubscribeAlertView show];
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

- (NSInteger)indexOfEC:(ExtracurricularUpdateStructure *)update {
     for (int i = 0; i < self.extracurricularsArray.count; i++) {
          if ([[update objectForKey:@"extracurricularID"] integerValue] == [[[self.extracurricularsArray objectAtIndex:i] objectForKey:@"extracurricularID"] integerValue]) {
               return i;
          }
     }
     return -1;
}

- (NSInteger)getIndexofStructureWithID:(NSNumber *)theID {
     for (int i = 0; i < self.extracurricularsArray.count; i++) {
          if (((ExtracurricularStructure *)(self.extracurricularsArray[i])).extracurricularID == theID)
               return i;
     }
     return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (indexPath.section == 0) {
          if (self.updatesArray.count > 0) {
               ECUDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ECUDetail"];
               ExtracurricularUpdateStructure *ECU = [self.updatesArray objectAtIndex:indexPath.row];
               ExtracurricularStructure *EC = [ECU getStructureForUpdate:ECU withArray:[self.extracurricularsArray copy]];
               controller.titleString = EC.titleString;
               controller.messageString = ECU.messageString;
               NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
               [dateFormatter setDateFormat:@"EEEE, MMMM d, YYYY @ h:mm a"];
               controller.dateString = [dateFormatter stringFromDate:ECU.postDate];
               [self.navigationController pushViewController:controller animated:YES];

          }
     } else if (indexPath.section == 1) {
          GroupMainTableViewController *controller = [[GroupMainTableViewController alloc] init];
          [self.navigationController pushViewController:controller animated:YES];
     }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
