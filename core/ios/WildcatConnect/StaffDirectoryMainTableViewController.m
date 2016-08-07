//
//  StaffDirectoryMainTableViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/14/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "StaffDirectoryMainTableViewController.h"
#import "StaffDirectoryResultsTableViewController.h"
#import "StaffMemberStructure.h"
#import "AppManager.h"
#import "ApplicationManager.h"

@interface StaffDirectoryMainTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) StaffDirectoryResultsTableViewController *resultsTableController;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation StaffDirectoryMainTableViewController {
     UIActivityIndicatorView *activity;
     BOOL isActive;
}

- (void)viewDidLoad {
     [super viewDidLoad];
     
     isActive = false;
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     _resultsTableController = [[StaffDirectoryResultsTableViewController alloc] init];
     _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
     self.searchController.searchResultsUpdater = self;
     [self.searchController.searchBar sizeToFit];
     self.tableView.tableHeaderView = self.searchController.searchBar;
     
     // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
     
     self.resultsTableController.tableView.delegate = self;
     self.searchController.delegate = self;
     self.searchController.dimsBackgroundDuringPresentation = NO;
     self.searchController.searchBar.delegate = self;
     
          // Search is now just presenting a view controller. As such, normal view controller
          // presentation semantics apply. Namely that presentation will walk up the view controller
          // hierarchy until it finds the root view controller or one that defines a presentation context.
          //
     
     self.definesPresentationContext = YES;
     if (self.loadNumber == [NSNumber numberWithInt:1]) {
          [self refreshData];
     } else {
          activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButton;
          [activity startAnimating];
          [self getOldDataWithCompletion:^(NSMutableArray *returnArray) {
                    //save the data
               self.staffMembers = returnArray;
               self.searchController.searchBar.placeholder = [[@"Search " stringByAppendingString:[NSString stringWithFormat:@"%lu", self.staffMembers.count]] stringByAppendingString:@" Staff Members"];
               [self testMethodTwoWithCompletion:^(NSError *error, NSMutableArray *dictionaryReturnArray) {
                    [self removeUnusedLettersWithCompletion:^(NSError *error, NSMutableArray *returnArray) {
                         self.dictionaryArray = returnArray;
                         dispatch_async(dispatch_get_main_queue(), ^ {
                              [activity stopAnimating];
                              [self.tableView reloadData];
                              self.navigationItem.rightBarButtonItem = nil;
                         });
                    } withArray:dictionaryReturnArray];
               } withArray:returnArray];
          }];
     }
}

- (void)getOldDataWithCompletion:(void (^)(NSMutableArray *returnArray))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
          //Start the first service
     dispatch_group_enter(serviceGroup);
     StaffMemberStructure *staffMemberStructure;
     NSMutableArray *array = [[NSMutableArray alloc] init];
     NSMutableArray *theArrayToSearch = [[NSUserDefaults standardUserDefaults] objectForKey:@"staffMembers"];
     NSDictionary *object;
     for (int i = 0; i < theArrayToSearch.count; i ++) {
          object = theArrayToSearch[i];
          staffMemberStructure = [[StaffMemberStructure alloc] init];
          staffMemberStructure.staffMemberEMail = [object objectForKey:@"staffMemberEMail"];
          staffMemberStructure.staffMemberFirstName = [object objectForKey:@"staffMemberFirstName"];
          staffMemberStructure.staffMemberLastName = [object objectForKey:@"staffMemberLastName"];
          staffMemberStructure.staffMemberLocation = [object objectForKey:@"staffMemberLocation"];
          staffMemberStructure.staffMemberTitle = [object objectForKey:@"staffMemberTitle"];
          [array addObject:staffMemberStructure];
          if (i == theArrayToSearch.count - 1)
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
     UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButton;
     [activity startAnimating];
     [self testMethodWithCompletion:^(NSError *error, NSMutableArray *returnArrayA) {
          self.staffMembers = returnArrayA;
          NSMutableArray *itemsToSave = [NSMutableArray array];
          for (StaffMemberStructure *s in returnArrayA) {
               [itemsToSave addObject:@{ @"staffMemberEMail"     : s.staffMemberEMail,
                                         @"staffMemberFirstName"    : s.staffMemberFirstName,
                                         @"staffMemberLastName" : s.staffMemberLastName,
                                         
                                         @"staffMemberLocation" : s.staffMemberLocation,
                                         
                                         @"staffMemberTitle" : s.staffMemberTitle
                                         
                                         }];
          }
          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
          [userDefaults setObject:itemsToSave forKey:@"staffMembers"];
          [self testMethodTwoWithCompletion:^(NSError *error, NSMutableArray *dictionaryReturnArray) {
               [self removeUnusedLettersWithCompletion:^(NSError *error, NSMutableArray *returnArray) {
                    self.dictionaryArray = returnArray;
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [activity stopAnimating];
                         [self.tableView reloadData];
                         self.navigationItem.rightBarButtonItem = nil;
                         self.searchController.searchBar.placeholder = [[@"Search " stringByAppendingString:[NSString stringWithFormat:@"%lu", self.staffMembers.count]] stringByAppendingString:@" Staff Members"];
                    });
               } withArray:dictionaryReturnArray];
          } withArray:returnArrayA];
     }];
}

- (void)testMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion {
     __block NSError *theError = nil;
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     NSMutableArray *returnArray = [[NSMutableArray alloc] init];
     PFQuery *query = [StaffMemberStructure query];
     [query orderByAscending:@"staffMemberLastName"];
     query.limit = 500;
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          [returnArray addObjectsFromArray:objects];
          theError = error;
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError)
               overallError = theError;
          completion(overallError, returnArray);
     });
}

- (void)testMethodTwoWithCompletion:(void (^)(NSError *error, NSMutableArray *dictionaryReturnArray))completion withArray:(NSMutableArray *)theArray {
     __block NSError *theError = nil;
     __block NSMutableArray *currentArrayLeft = theArray;
     NSMutableArray *array = [NSMutableArray new];
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     for (char a = 'A'; a <= 'Z'; a++) {
          NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
          NSMutableArray *words = [[NSMutableArray alloc] init];
          StaffMemberStructure *staffMemberStructure;
          for (int i = 0; i < currentArrayLeft.count; i++) {
               staffMemberStructure = currentArrayLeft[i];
               if (staffMemberStructure) {
                    if ([[staffMemberStructure.staffMemberLastName substringToIndex:1] isEqualToString:[NSString stringWithFormat:@"%c", a]]) {
                         [words addObject:staffMemberStructure];
                    }
               }
          }
          [row setValue:words forKey:@"rowValues"];
          [row setValue:[NSString stringWithFormat:@"%c", a] forKey:@"headerTitle"];
          [array addObject:row];
          if (a == 'Z') {
               dispatch_group_leave(serviceGroup);
          }
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(theError, array);
     });
}

     //- (void)testMethodTwoWithCompletion:(void (^)(NSError *error, NSMutableArray *dictionaryReturnArray))

- (void)removeUnusedLettersWithCompletion:(void (^)(NSError *error, NSMutableArray *returnArray))completion withArray:(NSMutableArray *)inputArray {
     __block NSError *theError = nil;
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
          //Loop through inputArray - if the dictionary at index i contains no objects in "rowValues" key, do not add to finalArray; else, add to final array
     NSMutableArray *finalArray = [[NSMutableArray alloc] init];
     NSDictionary *dictionary;
     for (int i = 0; i < inputArray.count; i++) {
          dictionary = [[NSDictionary alloc] init];
          dictionary = [inputArray objectAtIndex:i];
          if ([[dictionary objectForKey:@"rowValues"] count] > 0) {
               [finalArray addObject:dictionary];
          }
          if (i == inputArray.count - 1) {
               dispatch_group_leave(serviceGroup);
          }
     }
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(theError, finalArray);
     });
}

- (NSArray *)generateSectionsArray {
     NSMutableArray *currentArrayLeft = (NSMutableArray *)staffMembers;
     NSMutableArray *array = [NSMutableArray new];
     for (char a = 'A'; a <= 'Z'; a++) {
          NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
          NSMutableArray *words = [[NSMutableArray alloc] init];
          StaffMemberStructure *staffMemberStructure;
          for (int i = 0; i < currentArrayLeft.count; i++) {
               staffMemberStructure = [currentArrayLeft objectAtIndex:i];
               if ([[staffMemberStructure.staffMemberLastName substringToIndex:1] isEqualToString:[NSString stringWithFormat:@"%c", a]]) {
                    [words addObject:staffMemberStructure];
                    [currentArrayLeft removeObjectAtIndex:i];
               }
          }
          [row setValue:words forKey:@"rowValues"];
          [row setValue:[NSString stringWithFormat:@"%c", a] forKey:@"headerTitle"];
          [array addObject:row];
     }
     return array;
}

- (void)viewDidAppear:(BOOL)animated {
     [super viewDidAppear:animated];
     
          // restore the searchController's active state
     if (self.searchControllerWasActive) {
          self.searchController.active = self.searchControllerWasActive;
          _searchControllerWasActive = NO;
          
          if (self.searchControllerSearchFieldWasFirstResponder) {
               [self.searchController.searchBar becomeFirstResponder];
               _searchControllerSearchFieldWasFirstResponder = NO;
          }
     }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
     [searchBar resignFirstResponder];
}

#pragma mark - UISearchControllerDelegate

     // Called after the search controller's search bar has agreed to begin editing or when
     // 'active' is set to YES.
     // If you choose not to present the controller yourself or do not implement this method,
     // a default presentation is performed on your behalf.
     //
     // Implement this method if the default presentation is not adequate for your purposes.
     //
- (void)presentSearchController:(UISearchController *)searchController {
     isActive = true;
     [self.tableView reloadData];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
          // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
          // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
          // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
          // do something after the search controller is dismissed
     isActive = false;
     [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
          // Return the number of sections.
     if (self.dictionaryArray.count == 0)
          return 1;
     return [self.dictionaryArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
          // Return the number of rows in the section.else
     if (self.dictionaryArray.count == 0)
          return 1;
     return ((NSArray *)[[self.dictionaryArray objectAtIndex:section] objectForKey:@"rowValues"]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     if (self.dictionaryArray.count == 0) {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:@"cellID"];
          cell.textLabel.text = @"Loading your data...";
          return cell;
     }
     else {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:@"cellID"];
          NSArray *array = ((NSArray *)[[self.dictionaryArray objectAtIndex:[indexPath section]] objectForKey:@"rowValues"]);
          StaffMemberStructure *staffMemberStructure = (tableView == self.tableView) ? array[indexPath.row] : self.resultsTableController.filteredStaffMembers[indexPath.row];
          cell = [self configureCell:cell forStaffMemberStructure:staffMemberStructure];
          return cell;
     }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 70;
}

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber {
     self = [super init];
     self.loadNumber = theLoadNumber;
     self.navigationItem.title = @"Staff Directory";
     return self;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
     if (isActive) {
          return nil;
     } else {
          
          NSMutableArray *array = [[NSMutableArray alloc] init];
          for (char a = 'A'; a <= 'Z'; a++)
          {
               [array addObject:[NSString stringWithFormat:@"%c", a]];
          }
          return [NSArray arrayWithArray:array];
     }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
     if (self.tableView != tableView) {
          CGRect searchBarFrame = self.searchController.searchBar.frame;
          [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
          return NSNotFound;
     }
     else return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     if (! isActive)
          return [[self.dictionaryArray objectAtIndex:section] objectForKey:@"headerTitle"];
     else
          return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
          //udpate the filtered array based on the search text
     NSString *searchText = searchController.searchBar.text;
     NSMutableArray *searchResults = [self.staffMembers mutableCopy];
          //strip out all the leading and trailing spaces
     NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
          //break up the search terms (separated by spaces)
     NSArray *searchItems = nil;
     if (strippedString.length > 0) {
          searchItems = [strippedString componentsSeparatedByString:@" "];
     }
          //build all the "AND" expressions for each value in the search string
     NSMutableArray *andMatchPredicates = [NSMutableArray array];
     for (NSString *searchString in searchItems) {
               //each searchString creates an OR predicate for: lastName, firstName, title
          NSMutableArray *searchItemsPredicate = [NSMutableArray array];
               //Below we use NSExpression to represent expressions in our predicates.
               //Last name field matching
          NSExpression *lhs = [NSExpression expressionForKeyPath:@"staffMemberLastName"];
          NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
          NSPredicate *finalPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier type:NSBeginsWithPredicateOperatorType options:NSCaseInsensitivePredicateOption];
          [searchItemsPredicate addObject:finalPredicate];
               //First name field matching
          lhs = [NSExpression expressionForKeyPath:@"staffMemberFirstName"];
          rhs = [NSExpression expressionForConstantValue:searchString];
          finalPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier type:NSBeginsWithPredicateOperatorType options:NSCaseInsensitivePredicateOption];
          [searchItemsPredicate addObject:finalPredicate];
               //Title field matching
          lhs = [NSExpression expressionForKeyPath:@"staffMemberTitle"];
          rhs = [NSExpression expressionForConstantValue:searchString];
          finalPredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs rightExpression:rhs modifier:NSDirectPredicateModifier type:NSContainsPredicateOperatorType options:NSCaseInsensitivePredicateOption];
          [searchItemsPredicate addObject:finalPredicate];
               //add this OR predicate to our master AND predicate
          NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
          [andMatchPredicates addObject:orMatchPredicates];
     }
          //match up the fields of the StaffMemberStructure object
     NSCompoundPredicate *finalCompoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
     searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
          //hand over the filtered results to our search results table
     StaffDirectoryResultsTableViewController *tableController = (StaffDirectoryResultsTableViewController *)self.searchController.searchResultsController;
     tableController.filteredStaffMembers = searchResults;
     [tableController.tableView reloadData];
}

#pragma mark - UIStateRestoration

     // we restore several items for state restoration:
     //  1) Search controller's active state,
     //  2) search text,
     //  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
     [super encodeRestorableStateWithCoder:coder];
          //encode the view state so it can be restored later
          //encode the title
     [coder encodeObject:self.title forKey:ViewControllerTitleKey];
     UISearchController *searchController = self.searchController;
          //encode the searchController's active state
     BOOL searchDisplayControllerIsActive = searchController.isActive;
     [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
          //encode the first responder status
     if (searchDisplayControllerIsActive) {
          [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
     }
          //encode the search bar text
     [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
     [super decodeRestorableStateWithCoder:coder];
          //restore the title
     self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
          //restore the active state
          //we cna't make the searchController active here since it's not part of the view hierarchy yet, instead we will do it in viewWillAppear
     _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
          //restore the first responder status
     _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
          //restore the text in the search text field
     self.searchController.searchBar.text  = [coder decodeObjectForKey:SearchBarTextKey];
}

@end
