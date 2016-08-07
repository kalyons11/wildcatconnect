//
//  NewsArticleStructure.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Parse/Parse.h>

@interface NewsArticleStructure : PFObject<PFSubclassing>



+ (NSString *)parseClassName;

     //Properties

@property NSNumber *hasImage; // 0 = false, 1 = true
@property PFFile *imageFile;
@property NSString *titleString;
@property NSString *summaryString;
@property NSString *authorString;
@property NSString *dateString;
@property NSString *contentURLString;
@property NSNumber *articleID;
@property NSNumber *likes;
@property NSNumber *views;
@property NSNumber *isApproved;
@property NSString *userString;
@property NSString *email;

@end
