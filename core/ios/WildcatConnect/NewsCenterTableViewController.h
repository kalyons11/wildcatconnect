//
//  NewsCenterTableViewController.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/12/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsArticleStructure.h"

@interface NewsCenterTableViewController : UITableViewController {
     NSMutableArray *newsArticles;
     NSMutableArray *newsArticleImages;
     NSNumber *loadNumber;
     NewsArticleStructure *newsArticleSelected;
     NSMutableArray *readNewsArticles;
     NSMutableArray *dataArray;
}

@property (nonatomic, retain) NSMutableArray *newsArticles;
@property (nonatomic, retain) NSMutableArray *newsArticleImages;
@property (nonatomic, retain) NSNumber *loadNumber;
@property (nonatomic, retain) NewsArticleStructure *newsArticleSelected;
@property (nonatomic, retain) NSMutableArray *readNewsArticles;
@property (nonatomic, retain) NSMutableArray *dataArray;

- (instancetype)initWithLoadNumber:(NSNumber *)theLoadNumber;
- (void)replaceNewsArticleStructure:(NewsArticleStructure *)newsArticleStructure;

@end
