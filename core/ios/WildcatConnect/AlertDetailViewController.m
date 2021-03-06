//
//  AlertDetailViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/28/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "AlertDetailViewController.h"
#import "AlertsTableViewController.h"

@interface AlertDetailViewController ()

@end

@implementation AlertDetailViewController {
     UILabel *titleLabel;
     UIActivityIndicatorView *activity;
     UIScrollView *scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     [Utils setNavColorForController:self];
     
     self.navigationItem.title = @"Alert";
     
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     
     self.navigationController.navigationBar.translucent = NO;
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     titleLabel.text = self.alert.titleString;
     [titleLabel setFont:[UIFont systemFontOfSize:24]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     UILabel *authorDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     authorDateLabel.text = [[self.alert.authorString stringByAppendingString:@" | "] stringByAppendingString:self.alert.dateString];
     [authorDateLabel setFont:[UIFont systemFontOfSize:12]];
     authorDateLabel.lineBreakMode = NSLineBreakByWordWrapping;
     authorDateLabel.numberOfLines = 0;
     [authorDateLabel sizeToFit];
     [scrollView addSubview:authorDateLabel];
     
     UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, authorDateLabel.frame.origin.y + authorDateLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     [scrollView addSubview:[Utils createWebViewForDelegate:self forString:self.alert.contentString withSeparator:separator]];
     
          //Takes care of all resizing needs based on sizes.
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 60, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
     
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     self.alert.views = [NSNumber numberWithInteger:[self.alert.views integerValue] + 1];
     
     [self viewMethodWithCompletion:^(NSUInteger integer, NSError *error) {
          [activity stopAnimating];
          if (self.showCloseButton) {
               UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
               self.navigationItem.rightBarButtonItem = barButtonItem;
          }
     } forID:self.alert.objectId];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
     
     
     if (navigationType == UIWebViewNavigationTypeLinkClicked){
          
          [[UIApplication sharedApplication] openURL:request.URL];
          return NO;
          
     }
     
     else return YES;
     
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
     webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, webView.scrollView.contentSize.height);
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 150, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     
}

- (void)didReceiveMemoryWarning {
     [super didReceiveMemoryWarning];
          // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
     [super viewWillDisappear:animated];
          //Run method to pass current structure back to the tableView...
     if (! self.showCloseButton) {
          if ([self.navigationController.viewControllers objectAtIndex:0]) {
               AlertsTableViewController *viewController = (AlertsTableViewController *)[self.navigationController.viewControllers objectAtIndex:0];
               [viewController replaceAlertStructure:self.alert];
          }
     }
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewMethodWithCompletion:(void (^)(NSUInteger integer, NSError *error))completion forID:(NSString *)objectID {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [AlertStructure query];
     [query whereKey:@"alertID" equalTo:self.alert.alertID];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          theError = error;
          PFObject *object = (PFObject *)[objects firstObject];
          if (object != nil) {
               [object setObject:[NSNumber numberWithInteger:[[object objectForKey:@"views"] integerValue] + 1] forKey:@"views"];
               [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    theError = error;
                    dispatch_group_leave(serviceGroup);
               }];
          } else {
               dispatch_group_leave(serviceGroup);
          }
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError != nil) {
               overallError = theError;
          }
          completion(0, overallError);
     });
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
