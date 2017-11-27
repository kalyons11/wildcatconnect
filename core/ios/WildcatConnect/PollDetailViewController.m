//
//  PollDetailViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/8/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "PollDetailViewController.h"

@interface PollDetailViewController ()

@end

@implementation PollDetailViewController {
     UILabel *titleLabel;
     UIScrollView *scrollView;
     UITableView *thetableView;
     UIButton *postButton;
     UIView *separatorTwo;
     UILabel *thank;
}

@synthesize hasAnswered;
@synthesize pollStructure;

- (void)viewDidLoad {
    [super viewDidLoad];
     
     NSArray *testArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"answeredPolls"];
     
     if (! testArray || ! [testArray containsObject:self.pollStructure.pollID]) {
          self.hasAnswered = false;
     } else self.hasAnswered = true;
     
     self.choicesArray = [[NSMutableArray alloc] init];
     self.valuesArray = [[NSMutableArray alloc] init];
     
     self.choicesArray = [NSMutableArray arrayWithArray:[self.pollStructure.pollMultipleChoices allKeys]];
     self.valuesArray = [NSMutableArray arrayWithArray:[self.pollStructure.pollMultipleChoices allValues]];
    
     self.navigationItem.title = @"Poll";
     
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     titleLabel.text = self.pollStructure.pollTitle;
     [titleLabel setFont:[UIFont systemFontOfSize:24]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     questionLabel.text = self.pollStructure.pollQuestion;
     UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
     [questionLabel setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
     questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
     questionLabel.numberOfLines = 0;
     [questionLabel sizeToFit];
     [scrollView addSubview:questionLabel];
     
     UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, questionLabel.frame.origin.y + questionLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     thetableView = [[UITableView alloc] initWithFrame:CGRectMake(0, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width, 200)];
     [thetableView setDelegate:self];
     [thetableView setDataSource:self];
     [scrollView addSubview:thetableView];
     [thetableView reloadData];
     
     separatorTwo = [[UIView alloc] initWithFrame:CGRectMake(10, thetableView.frame.origin.y + thetableView.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separatorTwo.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separatorTwo];
     
     if (self.hasAnswered == NO) {
          
          postButton = [UIButton buttonWithType:UIButtonTypeSystem];
          [postButton setTitle:@"POST YOUR VOTE" forState:UIControlStateNormal];
          [postButton sizeToFit];
          [postButton addTarget:self action:@selector(voteMethod:) forControlEvents:UIControlEventTouchUpInside];
          postButton.frame = CGRectMake((self.view.frame.size.width / 2) - (postButton.frame.size.width / 2), separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
          [scrollView addSubview:postButton];
     } else {
          thank = [[UILabel alloc] init];
          thank.text = @"THANK YOU FOR VOTING!";
          UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
          [thank setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
          thank.lineBreakMode = NSLineBreakByWordWrapping;
          thank.numberOfLines = 0;
          [thank sizeToFit];
          thank.frame = CGRectMake((self.view.frame.size.width / 2) - (thank.frame.size.width / 2), separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, thank.frame.size.width, thank.frame.size.height);
          [scrollView addSubview:thank];
     }
     
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
}

- (void)voteMethod:(id)sender {
     if (self.checkedIndexPath) {
          UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
          [activity setBackgroundColor:[UIColor clearColor]];
          [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
          UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
          self.navigationItem.rightBarButtonItem = barButtonItem;
          [activity startAnimating];
          [postButton removeFromSuperview];
          thank = [[UILabel alloc] init];
          thank.text = @"SUBMITTING VOTE...";
          UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
          [thank setFont:[UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:font.pointSize]];
          [thank sizeToFit];
          thank.frame = CGRectMake((self.view.frame.size.width / 2) - (thank.frame.size.width / 2), separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, thank.frame.size.width, thank.frame.size.height);
          [scrollView addSubview:thank];
          [self postVoteMethodWithCompletion:^(NSDictionary *dictionary) {
               [self.pollStructure fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    self.pollStructure = (PollStructure *)object;
                    self.valuesArray = [NSMutableArray arrayWithArray:[self.pollStructure.pollMultipleChoices allValues]];
                    self.hasAnswered = true;
                    NSMutableArray *theArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"answeredPolls"] mutableCopy];
                    if (! theArray) {
                         theArray = [[NSMutableArray alloc] init];
                    }
                    if (! [theArray containsObject:self.pollStructure.pollID]) {
                         [theArray addObject:self.pollStructure.pollID];
                         [[NSUserDefaults standardUserDefaults] setObject:theArray forKey:@"answeredPolls"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"visitedPagesArray"];
                    if ([array containsObject:[NSString stringWithFormat:@"%lu", (long)4]]) {
                         NSMutableArray *newArray = [array mutableCopy];
                         [newArray removeObject:[NSString stringWithFormat:@"%lu", (long)4]];
                         [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:@"visitedPagesArray"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^ {
                         [activity stopAnimating];
                         [thank setText:@"THANK YOU FOR VOTING!"];
                         [thank sizeToFit];
                         thank.frame = CGRectMake((self.view.frame.size.width / 2) - (thank.frame.size.width / 2), separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, thank.frame.size.width, thank.frame.size.height);
                         [thetableView reloadData];
                    });
               }];
          } forChoiceIndex:(int)self.checkedIndexPath.row andID:self.pollStructure.pollID];
     } else {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You must select a response to this poll!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
          [alertView show];
     }
}

- (void)postVoteMethodWithCompletion:(void (^)(NSDictionary *dictionary))completion forChoiceIndex:(int)index andID:(NSString *)ID {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [PollStructure query];
     NSMutableDictionary *choicesDictionary = [NSMutableDictionary dictionary];
     __block PollStructure *thePoll = [[PollStructure alloc] init];
     [query getObjectInBackgroundWithId:self.pollStructure.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
          thePoll = (PollStructure *)object;
          [choicesDictionary addEntriesFromDictionary:self.pollStructure.pollMultipleChoices];
          NSNumber *newValue = [NSNumber numberWithInt:((NSNumber *)[choicesDictionary objectForKey:[choicesDictionary.allKeys objectAtIndex:index]]).integerValue + 1];
          [choicesDictionary setObject:newValue forKey:[self.choicesArray objectAtIndex:index]];
          thePoll.pollMultipleChoices = choicesDictionary;
          thePoll.pollID = ID;
          [thePoll saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               dispatch_group_leave(serviceGroup);
          }];
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          completion(choicesDictionary);
     });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
     if (indexPath.row < self.choicesArray.count) {
          cell.textLabel.text = [self.choicesArray objectAtIndex:indexPath.row];
          cell.textLabel.numberOfLines = 0;
          cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
          if (self.hasAnswered == true) {
               NSString *thisOne = [self.valuesArray objectAtIndex:indexPath.row];
               float thisF = [thisOne floatValue];
               NSString *total = self.pollStructure.totalResponses;
               float thisT = [total floatValue];
               float percent = 100 * (thisF / thisT);
               NSString *theString = [NSString stringWithFormat:@"%.1f", percent];
               if (isnan(percent)) {
                    percent = 0;
               }
               UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
               [downloadButton setTitle:[theString stringByAppendingString:@"%"] forState:UIControlStateNormal];
               [downloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
               downloadButton.enabled = false;
               [downloadButton sizeToFit];
               [downloadButton setFrame:CGRectMake(0, 0, downloadButton.frame.size.width, downloadButton.frame.size.height)];
               cell.accessoryView = downloadButton;
          } else {
               if([self.checkedIndexPath isEqual:indexPath])
               {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
               }
               else
               {
                    cell.accessoryType = UITableViewCellAccessoryNone;
               }
          }
     }
     return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return self.choicesArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (self.hasAnswered == NO) {
          if(self.checkedIndexPath)
          {
               UITableViewCell* uncheckCell = [tableView
                                               cellForRowAtIndexPath:self.checkedIndexPath];
               uncheckCell.accessoryType = UITableViewCellAccessoryNone;
          }
          if([self.checkedIndexPath isEqual:indexPath])
          {
               self.checkedIndexPath = nil;
          }
          else
          {
               UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
               cell.accessoryType = UITableViewCellAccessoryCheckmark;
               self.checkedIndexPath = indexPath;
          }
     }
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
