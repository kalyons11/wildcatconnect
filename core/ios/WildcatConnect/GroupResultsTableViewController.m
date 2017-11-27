//
//  GroupResultsTableViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/21/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "GroupResultsTableViewController.h"
#import "AddGroupButton.h"

@interface GroupResultsTableViewController ()

@end

@implementation GroupResultsTableViewController

@synthesize filteredGroups;

- (void)viewDidLoad {
     
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (self.filteredGroups.count == 0)
          return 1;
     return self.filteredGroups.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
     return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
          // Return the number of sections.
     return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     if (self.filteredGroups.count == 0) {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:@"cellID"];
          cell.textLabel.text = @"No results.";
          return cell;
     }
     else {
          UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                         reuseIdentifier:@"cellID"];
          ExtracurricularStructure *groupStructure = (ExtracurricularStructure *)[self.filteredGroups objectAtIndex:indexPath.row];
          cell = [self configureCell:cell forGroup:groupStructure];
          return cell;
     }
}

@end
