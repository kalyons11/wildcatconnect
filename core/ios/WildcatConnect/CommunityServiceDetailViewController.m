//
//  CommunityServiceDetailViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 2/16/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "CommunityServiceDetailViewController.h"

@interface CommunityServiceDetailViewController ()

@end

@implementation CommunityServiceDetailViewController {
     UILabel *titleLabel;
     UILabel *dateLabel;
     UILabel *dateLabelB;
     UITextView *messageLabel;
     UIScrollView *scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.navigationItem.title = @"Details";
     
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     
     self.navigationController.navigationBar.translucent = NO;
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     titleLabel.text = self.CS.commTitleString;
     [titleLabel setFont:[UIFont systemFontOfSize:24]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, self.view.frame.size.width - 20, 100)];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"EEEE, MMMM d, YYYY @ h:mm a"];
     NSString *dateString = [dateFormatter stringFromDate:self.CS.startDate];
     dateLabel.text = [@"Starts - " stringByAppendingString:dateString];
     [dateLabel setFont:[UIFont systemFontOfSize:18]];
     dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
     dateLabel.numberOfLines = 0;
     [dateLabel sizeToFit];
     [scrollView addSubview:dateLabel];
     
     dateLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, dateLabel.frame.origin.y + dateLabel.frame.size.height + 5, self.view.frame.size.width - 20, 100)];
     NSString *theDate = [dateFormatter stringFromDate:self.CS.endDate];
     dateLabelB.text = [@"Ends - " stringByAppendingString:theDate];
     [dateLabelB setFont:[UIFont systemFontOfSize:18]];
     dateLabelB.lineBreakMode = NSLineBreakByWordWrapping;
     dateLabelB.numberOfLines = 0;
     [dateLabelB sizeToFit];
     [scrollView addSubview:dateLabelB];
     
     UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, dateLabelB.frame.origin.y + dateLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     [scrollView addSubview:[Utils createWebViewForDelegate:self forString:self.CS.commSummaryString withSeparator:separator]];
     
     self.automaticallyAdjustsScrollViewInsets = YES;
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 70, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
