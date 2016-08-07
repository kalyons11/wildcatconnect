//
//  NewsCenterTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/12/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "NewsCenterTableViewController.h"
#import "AppManager.h"
#import "NewsArticleStructure.h"
#import "NewsArticleDetailViewController.h"

@implementation NewsCenterTableViewController {
     UIActivityIndicatorView *activity;
     BOOL isReloading;
}

- (void)viewDidLoad {
     [super viewDidLoad];
    UIRefreshControl *refreshControl= [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
     refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"PULL TO REFRESH"];
    self.refreshControl= refreshControl;
     
     isReloading = false;
     
     self.navigationItem.title = @"Wildcat News";
    
    if (self.loadNumber == [NSNumber numberWithInt:1] || ! self.loadNumber) {
               [self refreshData];
          }
          else {
               activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
               [activity setBackgroundColor:[UIColor clearColor]];
               [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
               UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
               self.navigationItem.rightBarButtonItem = barButtonItem;
               [activity startAnimating];
               [self getOldDataWithCompletion:^(NSMutableArray *returnArray) {
                    self.newsArticles = returnArray;
                    [self getOldImagesWithCompletion:^(NSMutableArray *returnArrayB, NSMutableArray *dataReturnArray) {
                         self.newsArticleImages = returnArrayB;
                         self.dataArray = dataReturnArray;
                         dispatch_async(dispatch_get_main_queue(), ^ {
                              [self.tableView reloadData];
                              [activity stopAnimating];
                              [self refreshControl];
                              UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Read All" style:UIBarButtonItemStylePlain target:self action:@selector(readAllMethod)];
                              self.navigationItem.rightBarButtonItem = barButtonItem;
                              [barButtonItem release];
                         });
                    }];
               }];
          }
}


/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsCenterTableViewController *selectednewsArticles = (tableView == self.tableView) ?
    self.newsArticles[indexPath.row] : self.resultsTableController.filteredProducts[indexPath.row];
    
    APLDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"APLDetailViewController"];
    detailViewController.product = selectedProduct; // hand off the current product to the detail view controller
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}*/

- (void)readAllMethod {
     NSMutableArray *readArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"] mutableCopy];
     if (! readArray) {
          readArray = [[NSMutableArray alloc] init];
     }
     for (NewsArticleStructure *NA in self.newsArticles) {
          if (! [readArray containsObject:NA.articleID]) {
               [readArray addObject:[NSNumber numberWithInteger:[NA.articleID integerValue]]];
          }
     }
     [[NSUserDefaults standardUserDefaults] setObject:readArray forKey:@"readNewsArticles"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     self.readNewsArticles = readArray;
     [self.tableView reloadData];
}

- (void)removeOldArrayObjectsWithCompletion:(void (^)(NSUInteger integer))completion withArray:(NSMutableArray *)array {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     NSMutableArray *theArray = [array mutableCopy];
     NSMutableArray *dictionaryArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"];
     NSMutableArray *searchDictionaryArray = [dictionaryArray mutableCopy];
     NSMutableArray *likedArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"likedNewsArticles"];
     NSMutableArray *likesDictionaryArray = [likedArray mutableCopy];
          //Have some objects to remove...
     NSMutableArray *currentArray = [NSMutableArray array];
     
     for (NewsArticleStructure *NA in theArray) {
          [currentArray addObject:NA.articleID];
     }
     
     NSMutableArray *twoArray = [searchDictionaryArray mutableCopy];
     
     for (NSNumber *number in searchDictionaryArray) {
          if (! [currentArray containsObject:number]) {
               [twoArray removeObject:number];
          }
     }
     
     [[NSUserDefaults standardUserDefaults] setObject:twoArray forKey:@"readNewsArticles"];
     
     NSMutableArray *threeArray = [likesDictionaryArray mutableCopy];
     
     for (NSNumber *number in searchDictionaryArray) {
          if (! [currentArray containsObject:number]) {
               [threeArray removeObject:number];
          }
     }
     
     [[NSUserDefaults standardUserDefaults] setObject:threeArray forKey:@"likedNewsArticles"];
     
     [[NSUserDefaults standardUserDefaults] synchronize];
     dispatch_group_leave(serviceGroup);
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(0);
     });
}

- (void)getOldImagesWithCompletion:(void (^)(NSMutableArray *returnArray, NSMutableArray *dataArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theDataArray = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"newsArticleImages"];
     NSData *data;
     UIImage *image;
     for (int i = 0; i < theArrayToSearch.count; i++) {
          data = theArrayToSearch[i];
          image = [UIImage imageWithData:data];
          [theDataArray addObject:data];
          if (image) {
               if (image.size.width > 70) {
                    image = [[AppManager getInstance] imageFromImage:image scaledToWidth:70];
               }
               [array addObject:image];
          }
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
          completion(array, theDataArray);
     });
}

- (void)getOldDataWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     NewsArticleStructure *newsArticleStructure;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"newsArticles"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i ++) {
          object = theArrayToSearch[i];
          newsArticleStructure = [[NewsArticleStructure alloc] init];
          newsArticleStructure.articleID = [object objectForKey:@"articleID"];
          newsArticleStructure.authorString = [object objectForKey:@"authorString"];
          newsArticleStructure.contentURLString = [object objectForKey:@"contentURLString"];
          newsArticleStructure.dateString = [object objectForKey:@"dateString"];
          newsArticleStructure.hasImage = [object objectForKey:@"hasImage"];
          newsArticleStructure.likes = [object objectForKey:@"likes"];
          newsArticleStructure.summaryString = [object objectForKey:@"summaryString"];
          newsArticleStructure.titleString = [object objectForKey:@"titleString"];
          newsArticleStructure.views = [object objectForKey:@"views"];
          [array addObject:newsArticleStructure];
          if (i == theArrayToSearch.count - 1)
               dispatch_group_leave(serviceGroup);
     }
     if (theArrayToSearch.count == 0) {
          dispatch_group_leave(serviceGroup);
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(array);
     });
}

- (void)refreshData {
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     [self testMethodWithCompletion:^(NSError *error, NSMutableArray *returnArrayA) {
          if (error) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    [self.tableView reloadData];
                    [self refreshControl];
               });
          } else {
               self.newsArticles = returnArrayA;
               [self removeOldArrayObjectsWithCompletion:^(NSUInteger integer) {
                    NSMutableArray *itemsToSave = [NSMutableArray array];
                    for (NewsArticleStructure *n in returnArrayA) {
                         [itemsToSave addObject:@{ @"hasImage"     : n.hasImage,
                                                   @"titleString" : n.titleString,
                                                   
                                                   @"summaryString" : n.summaryString,
                                                   
                                                   @"authorString" : n.authorString,
                                                   
                                                   @"dateString" : n.dateString,
                                                   
                                                   @"contentURLString" : n.contentURLString,
                                                   
                                                   @"articleID" : n.articleID,
                                                   
                                                   @"likes" : n.likes,
                                                   
                                                   @"views" : n.views
                                                   
                                                   }];
                    }
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:itemsToSave forKey:@"newsArticles"];
                    NSMutableArray *readArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"];
                    if (! readArray) {
                         self.readNewsArticles = [NSMutableArray array];
                    } else
                         self.readNewsArticles = [readArray mutableCopy];
                    [self testMethodTwoWithCompletion:^(NSError *error, NSMutableArray *returnArray, NSMutableArray *theReturnDataArray) {
                         if (error) {
                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                              [alertView show];
                              dispatch_async(dispatch_get_main_queue(), ^ {
                                   [activity stopAnimating];
                                   [self.tableView reloadData];
                                   [self refreshControl];
                              });
                         } else {
                              self.newsArticleImages = returnArray;
                              self.dataArray = theReturnDataArray;
                              NSMutableArray *moreItems = [NSMutableArray array];
                              for (int i = 0; i < theReturnDataArray.count; i++) {
                                   [moreItems addObject:theReturnDataArray[i]];
                              }
                              [userDefaults setObject:moreItems forKey:@"newsArticleImages"];
                              [userDefaults synchronize];
                              dispatch_async(dispatch_get_main_queue(), ^ {
                                   [activity stopAnimating];
                                   [self.tableView reloadData];
                                   [self refreshControl];
                                   UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Read All" style:UIBarButtonItemStylePlain target:self action:@selector(readAllMethod)];
                                   self.navigationItem.rightBarButtonItem = barButtonItem;
                                   [barButtonItem release];
                              });
                         }
                    } withArray:returnArrayA];
               } withArray:returnArrayA];
          }
     }];
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
     if (self.newsArticles.count > 0) {
          NSMutableArray *itemsToSave = [NSMutableArray array];
          for (NewsArticleStructure *n in self.newsArticles) {
               [itemsToSave addObject:@{ @"hasImage"     : n.hasImage,
                                         @"titleString" : n.titleString,
                                         
                                         @"summaryString" : n.summaryString,
                                         
                                         @"authorString" : n.authorString,
                                         
                                         @"dateString" : n.dateString,
                                         
                                         @"contentURLString" : n.contentURLString,
                                         
                                         @"articleID" : n.articleID,
                                         
                                         @"likes" : n.likes,
                                         
                                         @"views" : n.views
                                         
                                         }];
          }
          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
          [userDefaults setObject:itemsToSave forKey:@"newsArticles"];
          NSMutableArray *moreItems = [NSMutableArray array];
          for (int i = 0; i < self.dataArray.count; i++) {
               [moreItems addObject:self.dataArray[i]];
          }
          [userDefaults setObject:moreItems forKey:@"newsArticleImages"];
          [userDefaults setObject:self.readNewsArticles forKey:@"readNewsArticles"];
          [userDefaults synchronize];
     }
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber {
     self = [super init];
     self.loadNumber = theLoadNumber;
     self.navigationItem.title = @"News Center";
     return self;
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     NSMutableArray *readArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"];
     if (! readArray) {
          self.readNewsArticles = [NSMutableArray array];
     } else
          self.readNewsArticles = [readArray mutableCopy];
     [self.tableView reloadData];
}

- (void)testMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
          //Define errors to be processed when everything is complete.
          //One error per service; in this example we'll have two
     __block NSError *firstError = nil;
          //Create the dispatch group
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
      NSMutableArray *returnArray = [[NSMutableArray alloc] init];
     PFQuery *query = [NewsArticleStructure query];
     [query whereKey:@"isApproved" equalTo:[NSNumber numberWithInteger:1]];
     [query orderByDescending:@"articleID"];
     query.limit = 25;
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          [returnArray addObjectsFromArray:objects];
          firstError = error;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          NSError *overallError = nil;
          if (firstError)
               overallError = firstError;
          completion(overallError, returnArray);
     });
}

- (void)testMethodTwoWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray, NSMutableArray *returnDataArray))completion withArray:(NSMutableArray *)array {
     __block NSError *theError = nil;
     dispatch_group_t theServiceGroup = dispatch_group_create();
     dispatch_group_enter(theServiceGroup);
     NSMutableArray *theReturnArray = [NSMutableArray arrayWithArray:array];
     NSMutableArray *theReturnDataArray = [NSMutableArray arrayWithArray:array];
     NewsArticleStructure *ECStructure;
     for (int i = 0; i < array.count; i++) {
          ECStructure = (NewsArticleStructure *)[array objectAtIndex:i];
          NSInteger imageInteger = [ECStructure.hasImage integerValue];
          if (imageInteger == 1) {
               PFFile *file = ECStructure.imageFile;
               [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    theError = error;
                    UIImage *image = [UIImage imageWithData:data];
                    image = [[AppManager getInstance] imageFromImage:image scaledToWidth:70];
                    [theReturnArray setObject:image atIndexedSubscript:[[NSNumber numberWithInt:i] integerValue]];
                    [theReturnDataArray setObject:data atIndexedSubscript:i];
                        BOOL go = true;
                        for (NSObject *object in theReturnArray) {
                            if (object.class == [NewsArticleStructure class]) {
                                go = false;
                                break;
                            }
                        }
                        if (go) {
                            dispatch_group_leave(theServiceGroup);
                        }
               }];
          } else {
               [theReturnArray setObject:[[NSObject alloc] init] atIndexedSubscript:[[NSNumber numberWithInt:i] integerValue]];
               [theReturnDataArray setObject:[[NSData alloc] init] atIndexedSubscript:i];
               BOOL go = true;
               if (i == array.count - 1) {
                    for (NSObject *object in theReturnArray) {
                         if (object.class == [NewsArticleStructure class]) {
                              go = false;
                              break;
                         }
                    }
                    if (go) {
                         dispatch_group_leave(theServiceGroup);
                    }
               }
          }
     }
     if (array.count == 0) {
          dispatch_group_leave(theServiceGroup);
     }
     dispatch_group_notify(theServiceGroup, dispatch_get_main_queue(), ^{
          NSError *overallError = nil;
          if (theError)
               overallError = theError;
          completion(overallError, theReturnArray, theReturnDataArray);
     });
}

- (void)didReceiveMemoryWarning {
     [super didReceiveMemoryWarning];
          // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
          // Return the number of sections.
     return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
          // Return the number of rows in the section.
     if (self.newsArticles.count == 0)
          return 1;
     return self.newsArticles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 100;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 // Configure the cell...
      if (self.newsArticles.count == 0) {
           UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
           cell.textLabel.text = @"Loading your data...";
           return  cell;
      } else {
           if ([self.newsArticles objectAtIndex:indexPath.row] && [self.newsArticleImages objectAtIndex:indexPath.row]) {
                NewsArticleStructure *newsArticleStructure = ((NewsArticleStructure *)[self.newsArticles objectAtIndex:indexPath.row]);
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
                cell.textLabel.text = newsArticleStructure.titleString;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.detailTextLabel.text = newsArticleStructure.summaryString;
                cell.detailTextLabel.numberOfLines = 4;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if ([[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Administration"]) {
                          //Show the views...
                     cell.detailTextLabel.text = [[[newsArticleStructure.summaryString stringByAppendingString:@" - "] stringByAppendingString:[newsArticleStructure.views stringValue]] stringByAppendingString:@" VIEWS"];
                }
                NSInteger integerNumber = [newsArticleStructure.hasImage integerValue];
                if (! [self.readNewsArticles containsObject:newsArticleStructure.articleID]) {
                     UIButton *unreadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                     [unreadButton setImage:[UIImage imageNamed:@"unread@2x.png"] forState:UIControlStateNormal];
                     [unreadButton setEnabled:NO];
                     [unreadButton sizeToFit];
                     cell.accessoryView = unreadButton;
                     [cell setNeedsLayout];
                }
                if (integerNumber == 1 && self.newsArticleImages.count > 0)
                     if ([[self.newsArticleImages objectAtIndex:indexPath.row] class] == [UIImage class]) {
                          cell.imageView.image = (UIImage *)[self.newsArticleImages objectAtIndex:indexPath.row];
                     }
                return cell;
           } else return nil;
      }
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (self.newsArticles.count > 0) {
          self.newsArticleSelected = self.newsArticles[indexPath.row];
          NewsArticleDetailViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"NADetail"];
          controller.NA = self.newsArticleSelected;
          if (self.dataArray.count > 0) {
               controller.imageData = self.dataArray[indexPath.row];
          }
          [self.navigationController pushViewController:controller animated:YES];
          NSMutableArray *theReadNews = [[[NSUserDefaults standardUserDefaults] objectForKey:@"readNewsArticles"] mutableCopy];
          if (! theReadNews) {
               theReadNews = [[NSMutableArray alloc] init];
          }
          if (! [theReadNews containsObject:self.newsArticleSelected.articleID]) {
               [theReadNews addObject:self.newsArticleSelected.articleID];
               [[NSUserDefaults standardUserDefaults] setObject:theReadNews forKey:@"readNewsArticles"];
               self.readNewsArticles = theReadNews;
               [[NSUserDefaults standardUserDefaults] synchronize];
          }
     }
}



#pragma mark Table View Data Sources Methods;

/*-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section:return [self.newsArticles count];

*/

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

 #pragma mark - Navigation
     //In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
      if ([segue.identifier isEqualToString:@"showDetailView"]) {
           NewsArticleDetailViewController *detailViewController = (NewsArticleDetailViewController *)[segue destinationViewController];
           detailViewController.NA = self.newsArticleSelected;
      }
 }

#pragma mark - Helper Methods

- (void)replaceNewsArticleStructure:(NewsArticleStructure *)newsArticleStructure {
     NSNumber *index = newsArticleStructure.articleID;
     NewsArticleStructure *structure;
     for (int i = 0; i < self.newsArticles.count; i++) {
          structure = (NewsArticleStructure *)self.newsArticles[i];
          if (structure.articleID == index) {
               [self.newsArticles[i] setObject:[newsArticleStructure objectForKey:@"views"] forKey:@"views"];
          }
     }
     isReloading = true;
     [self.tableView reloadData];
}

@end