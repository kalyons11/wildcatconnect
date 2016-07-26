//
//  AppManager.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 8/13/15.
//  Copyright (c) 2015 WildcatConnect. All rights reserved.
//

#import "AppManager.h"
#import <Parse/Parse.h>
#import "NewsArticleStructure.h"
#import "StaffMemberStructure.h"

@implementation AppManager

/*@synthesize newsArticles;
@synthesize newsArticleImages;
@synthesize likedNewsArticles;
@synthesize staffMembers;*/

static AppManager *instance = nil;

+ (AppManager *)getInstance {
     @synchronized(self) {
          if (instance == nil) {
               instance = [AppManager new];
          }
     }
     return instance;
}

- (UIImage *)imageFromImage:(UIImage *)sourceImage scaledToWidth:(float)imageWidth {
     float oldWidth = sourceImage.size.width;
     float scaleFactor = imageWidth / oldWidth;
     float newHeight = sourceImage.size.height * scaleFactor;
     float newWidth = oldWidth * scaleFactor;
     UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
     [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
     UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
     return newImage;
}

- (void)loadUserDefaults {
     likedNewsArticles = [[NSUserDefaults standardUserDefaults] valueForKey:@"likedNewsArticles"];\
}

- (void)saveUserDefaults {
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     NSArray *likedNewsArticlesArray = [NSArray arrayWithArray:likedNewsArticles];
     [userDefaults setObject:likedNewsArticlesArray forKey:@"likedNewsArticles"];
     [userDefaults synchronize];
}

- (void)loadAllData:(NSObject *)object forViewController:(UIViewController *)viewController {
     [self loadUserDefaults];
     dispatch_async(dispatch_get_main_queue(), ^(void) {
          [(UIActivityIndicatorView *)object stopAnimating];
          [viewController performSegueWithIdentifier:@"showApplicationSegue" sender:viewController];
     });
}

- (void)loadNewsArticles:(NSObject *)object forViewController:(UIViewController *)viewController {
     newsArticleImages = [[NSMutableArray alloc] init];
     newsArticles = [[NSMutableArray alloc] init];
     PFQuery *query = [NewsArticleStructure query];
     [query orderByAscending:@"createdAt"];
     query.limit = 10;
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          if (! error) {
               self.newsArticles = (NSMutableArray *)objects;
               NewsArticleStructure *newsArticleStructure;
               for (int i = 0; i < newsArticles.count; i++) {
                    newsArticleStructure = (NewsArticleStructure *)[newsArticles objectAtIndex:i];
                    PFFile *file = newsArticleStructure.imageFile;
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                         if (! error) {
                              UIImage *image = [UIImage imageWithData:data];
                              image = [self imageFromImage:image scaledToWidth:70];
                              [self.newsArticleImages addObject:image];
                         }
                    }];
               }
               dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [(UIActivityIndicatorView *)object stopAnimating];
                    [viewController performSegueWithIdentifier:@"showApplicationSegue" sender:viewController];
               });
          }
     }];
}

- (void)loadStaffDirectory {
     staffMembers = [[NSMutableArray alloc] init];
     PFQuery *query = [StaffMemberStructure query];
     [query orderByDescending:@"staffMemberLastName"];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          if (! error) {
               self.staffMembers = (NSMutableArray *)objects;
               instance = self;
               dispatch_async(dispatch_get_main_queue(), ^(void) {
                         //
               });
          }
     }];
}

- (NSMutableArray *)getStaffMembers {
     return self.staffMembers;
}

@end
