//
//  AppManager.h
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppManager : NSObject {
    
   
    
    NSMutableArray *newsArticles;
     NSMutableArray *newsArticleImages;
     NSMutableArray *likedNewsArticles;
     NSMutableArray *staffMembers;
}

@property (nonatomic, retain) NSMutableArray *newsArticles;
@property (nonatomic, retain) NSMutableArray *newsArticleImages;
@property (nonatomic, retain) NSMutableArray *likedNewsArticles;
@property (nonatomic, retain) NSMutableArray *staffMembers;

+ (AppManager *)getInstance;
- (UIImage *)imageFromImage:(UIImage *)sourceImage scaledToWidth:(float)imageWidth;

- (void)loadAllData:(NSObject *)object forViewController:(UIViewController *)viewController;

- (void)loadUserDefaults;
- (void)saveUserDefaults;

- (void)loadNewsArticles:(NSObject *)object forViewController:(UIViewController *)viewController;
- (void)loadStaffDirectory;

- (NSMutableArray *)getStaffMembers;

@end
