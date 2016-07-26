//
//  CapstoneViewController.m
//  WildcatConnect
//
//  Created by Kevin Lyons on 12/29/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "CapstoneViewController.h"

@interface CapstoneViewController ()

@end

@implementation CapstoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     
     UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, 100)];
     textView.text = @"WildcatConnect is a product of the Weymouth High School Capstone requirement. It seeks to answer the essential question, \"How can a mobile application for key announcements and information foster a more active school community?\" With over 75,000 lines of code spanning 5 languages, the system itself is as functional and user-friendly as possible.\n\nWildcatConnect is a non-profit application, with no revenue generated from any sort of advertising. A small amount of funding was generously provided by Weymouth High School to get the development process moving.\n\nAs always, if you have any questions, comments or concerns about the application, please let us know. You can reach us at team@wildcatconnect.org.\n\nBest,\n\nRohith and Kevin\n\nLead Developers\nWildcatConnect";
     textView.font = [UIFont systemFontOfSize:18];
     textView.editable = false;
     textView.scrollEnabled = true;
     textView.dataDetectorTypes = UIDataDetectorTypeLink;
     [textView sizeToFit];
     [scrollView addSubview:textView];
     
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 0, 0);
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
