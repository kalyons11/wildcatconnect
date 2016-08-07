//
//  CustomLoginSegue.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 10/10/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "CustomLoginSegue.h"

@implementation CustomLoginSegue

- (void) perform {
     UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
     UIViewController *destinationController = (UIViewController*)[self destinationViewController];
     UINavigationController *navigationController = sourceViewController.navigationController;
          // Pop to root view controller (not animated) before pushing
     [navigationController popToRootViewControllerAnimated:NO];
     [navigationController pushViewController:destinationController animated:YES];
}

@end
