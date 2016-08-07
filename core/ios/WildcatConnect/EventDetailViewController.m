//
//  EventDetailViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 1/16/16.
//  Copyright © 2016 WildcatConnect. All rights reserved.
//

#import "EventDetailViewController.h"

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController {
     UILabel *titleLabel;
     UILabel *locationLabel;
     UILabel *dateLabel;
     UITextView *messageLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     self.navigationItem.title = @"Event Details";
     
     UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 100)];
     titleLabel.text = self.event.titleString;
     [titleLabel setFont:[UIFont systemFontOfSize:24]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, self.view.frame.size.width - 20, 100)];
     locationLabel.text = [@"Location - " stringByAppendingString:self.event.locationString];
     [locationLabel setFont:[UIFont systemFontOfSize:18]];
     locationLabel.lineBreakMode = NSLineBreakByWordWrapping;
     locationLabel.numberOfLines = 0;
     [locationLabel sizeToFit];
     [scrollView addSubview:locationLabel];
     
     dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, locationLabel.frame.origin.y + locationLabel.frame.size.height + 5, self.view.frame.size.width - 20, 100)];
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"EEEE, MMMM d, YYYY @ h:mm a"];
     NSString *dateString = [dateFormatter stringFromDate:self.event.eventDate];
     dateLabel.text = [@"Date - " stringByAppendingString:dateString];
     [dateLabel setFont:[UIFont systemFontOfSize:18]];
     dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
     dateLabel.numberOfLines = 0;
     [dateLabel sizeToFit];
     [scrollView addSubview:dateLabel];
     
     UIView * separator = [[UIView alloc] initWithFrame:CGRectMake(10, dateLabel.frame.origin.y + dateLabel.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, separator.frame.origin.y + separator.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
     messageLabel.text = self.event.messageString;
     messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
     messageLabel.editable = false;
     messageLabel.scrollEnabled = false;
     [messageLabel setFont:[UIFont systemFontOfSize:16]];
     [messageLabel sizeToFit];
     [scrollView addSubview:messageLabel];
     
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
