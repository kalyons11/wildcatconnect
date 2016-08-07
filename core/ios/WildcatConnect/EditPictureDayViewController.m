//
//  EditPictureDayViewController.m
//  WildcatConnectGITTest
//
//  Created by Kevin Lyons on 11/22/15.
//  Copyright © 2015 WildcatConnect. All rights reserved.
//

#import "EditPictureDayViewController.h"
#import "SchoolDayStructure.h"
#import <Parse/Parse.h>
#import "AppManager.h"

@interface EditPictureDayViewController ()

@end

@implementation EditPictureDayViewController {
     UIActivityIndicatorView *activity;
     UIScrollView *scrollView;
     UILabel *titleLabel;
     NSNumber *hasImage;
     NSData *imageData;
     NSString *schoolDayID;
     NSString *imageUser;
     NSString *imageUserFullString;
     UILabel *imageLabelB;
     UIButton *removeButton;
     BOOL hasChanged;
     UIImageView *imageView;
     UIView *separator;
     UIButton *postButton;
     UIAlertView *postAlertView;
     UITextView *captionTextView;
     UILabel *captionLabel;
     NSString *captionString;
     BOOL keyboardIsShown;
     NSString *finalString;
     UIView *separatorTwo;
     UIAlertView *checkAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
     hasChanged = false;
     
     hasImage = false;
     imageData = [NSData data];
     imageUser = [[NSString alloc] init];
     schoolDayID = [[NSString alloc] init];
     imageUserFullString = [[NSString alloc] init];
     
     self.dayString = [[NSString alloc] init];
     
     UIBarButtonItem *bbtnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(goBack:)];
     
     self.navigationItem.leftBarButtonItem = bbtnBack;
     
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
     
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(keyboardWillShow:)
                                                  name:UIKeyboardWillShowNotification
                                                object:self.view.window];
          // register for keyboard notifications
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(keyboardWillHide:)
                                                  name:UIKeyboardWillHideNotification
                                                object:self.view.window];
     keyboardIsShown = NO;
     
     self.navigationItem.title = @"Picture of the Day";
     
     self.navigationController.navigationBar.translucent = NO;
     
     activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
     [activity setBackgroundColor:[UIColor clearColor]];
     [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
     self.navigationItem.rightBarButtonItem = barButtonItem;
     [activity startAnimating];
     
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248.0f/255.0f
                                                                            green:183.0f/255.0f
                                                                             blue:23.0f/255.0f
                                                                            alpha:0.5f];
     
     titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 50)];
     titleLabel.text = @"Loading today's image...";
     [titleLabel setFont:[UIFont systemFontOfSize:16]];
     titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
     titleLabel.numberOfLines = 0;
     [titleLabel sizeToFit];
     [scrollView addSubview:titleLabel];
     
     [self getCurrentSchoolDayMethodWithCompletion:^(NSError *error, NSMutableArray *schoolDay) {
          if (error != nil) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data from server. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [alertView show];
               dispatch_async(dispatch_get_main_queue(), ^ {
                    [activity stopAnimating];
                    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(viewDidLoad)];
                    self.navigationItem.rightBarButtonItem = barButtonItem;
                    [activity startAnimating];
               });
          } else {
               NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
               [dateFormatter setDateFormat:@"MM-dd-yyyy"];
               NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
               NSString *potentialString = [[schoolDay objectAtIndex:0] objectForKey:@"schoolDate"];
               NSInteger index = 0;
               if ([dateString isEqualToString:potentialString]) {
                    [dateFormatter setDateFormat:@"H"];
                    dateString = [dateFormatter stringFromDate:[NSDate date]];
                    NSInteger hour = [dateString integerValue];
                    if (hour >= 17) {
                         index = 1;
                    }
               }
                    hasImage = [[schoolDay objectAtIndex:index] objectForKey:@"hasImage"];
                    schoolDayID = [[schoolDay objectAtIndex:index] objectForKey:@"schoolDayID"];
               self.dayString = [[[schoolDay objectAtIndex:index] objectForKey:@"schoolDayID"] copy];
                    imageUser = [[schoolDay objectAtIndex:index] objectForKey:@"imageUser"];
               imageUserFullString = [[schoolDay objectAtIndex:index] objectForKey:@"imageUserFullString"];
               captionString = [[schoolDay objectAtIndex:index] objectForKey:@"imageString"];
               if ([hasImage integerValue] == 1) {
                    [self getImageDataMethodWithCompletion:^(NSError *error, NSMutableArray *returnData, NSString *returnString, NSString *returnImageString, NSString *fullPostString) {
                         [activity stopAnimating];
                         imageData = [returnData objectAtIndex:0];
                         UIImage *image = [[UIImage alloc] init];
                         
                         image = [UIImage imageWithData:imageData];
                         
                         [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                         NSDate *theDate = [dateFormatter dateFromString:[[schoolDay objectAtIndex:index] objectForKey:@"schoolDate"]];
                         [dateFormatter setDateFormat:@"EEEE"];
                         NSString *theString = [dateFormatter stringFromDate:theDate];
                         
                         titleLabel.text = [theString stringByAppendingString:@"'s Picture"];
                         [titleLabel sizeToFit];
                         
                         imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 300)];
                         
                         if (image.size.width > self.view.frame.size.width - 20) {
                              image = [[AppManager getInstance] imageFromImage:image scaledToWidth:self.view.frame.size.width - 20];
                         }
                         imageView.image = image;
                         [imageView sizeToFit];
                         imageView.frame = CGRectMake(self.view.frame.size.width / 2 - imageView.frame.size.width / 2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, imageView.frame.size.width, imageView.frame.size.height);
                         [scrollView addSubview:imageView];
                         
                              imageLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                              [imageLabelB setFont:[UIFont systemFontOfSize:16]];
                         
                         imageLabelB.text = fullPostString;
                         [imageLabelB sizeToFit];
                         [scrollView addSubview:imageLabelB];
                         
                         NSString *myUserString = [[[[PFUser currentUser] objectForKey:@"lastName"] stringByAppendingString:@", "] stringByAppendingString:[[PFUser currentUser] objectForKey:@"firstName"]];
                         
                         if ([myUserString isEqual:returnString] || [[[PFUser currentUser] objectForKey:@"userType"] isEqualToString:@"Developer"]) {
                              
                              separatorTwo = [[UIView alloc] initWithFrame:CGRectMake(10, imageLabelB.frame.origin.y + imageLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                              separatorTwo.backgroundColor = [UIColor blackColor];
                              [scrollView addSubview:separatorTwo];
                              
                              captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                              [captionLabel setFont:[UIFont systemFontOfSize:16]];
                              
                              captionLabel.text = @"Caption";
                              [captionLabel sizeToFit];
                              [scrollView addSubview:captionLabel];
                              
                              captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, captionLabel.frame.origin.y + captionLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
                              captionTextView.text = returnImageString;
                              captionTextView.editable = true;
                              captionTextView.scrollEnabled = true;
                              [captionTextView setDelegate:self];
                              [captionTextView setFont:[UIFont systemFontOfSize:16]];
                              captionTextView.layer.borderWidth = 1.0f;
                              captionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
                              captionTextView.dataDetectorTypes = UIDataDetectorTypeLink;
                              [scrollView addSubview:captionTextView];
                              
                              removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
                              [removeButton setTitle:@"EDIT PICTURE" forState:UIControlStateNormal];
                              [removeButton sizeToFit];
                              [removeButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
                              removeButton.frame = CGRectMake((self.view.frame.size.width - removeButton.frame.size.width - 10), captionTextView.frame.origin.y + captionTextView.frame.size.height + 10, removeButton.frame.size.width, removeButton.frame.size.height);
                              [scrollView addSubview:removeButton];
                              
                              [scrollView removeFromSuperview];
                              UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 130, 0);
                              scrollView.contentInset = adjustForTabbarInsets;
                              scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                              CGRect contentRect = CGRectZero;
                              for (UIView *view in scrollView.subviews) {
                                   contentRect = CGRectUnion(contentRect, view.frame);
                              }
                              scrollView.contentSize = contentRect.size;
                              [self.view addSubview:scrollView];
                         } else {
                              
                              imageLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                              [imageLabelB setFont:[UIFont systemFontOfSize:16]];
                              imageLabelB.text = [imageLabelB.text stringByAppendingString:@" - Contact this user to change the Picture of the Day."];
                              imageLabelB.lineBreakMode = NSLineBreakByWordWrapping;
                              imageLabelB.numberOfLines = 0;
                              [imageLabelB sizeToFit];
                              
                              separatorTwo = [[UIView alloc] initWithFrame:CGRectMake(10, imageLabelB.frame.origin.y + imageLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
                              separatorTwo.backgroundColor = [UIColor blackColor];
                              [scrollView addSubview:separatorTwo];
                              
                              captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                              [captionLabel setFont:[UIFont systemFontOfSize:16]];
                              
                              captionLabel.text = returnImageString;
                              [captionLabel sizeToFit];
                              [scrollView addSubview:captionLabel];
                              
                              [scrollView removeFromSuperview];
                              UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 130, 0);
                              scrollView.contentInset = adjustForTabbarInsets;
                              scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                              CGRect contentRect = CGRectZero;
                              for (UIView *view in scrollView.subviews) {
                                   contentRect = CGRectUnion(contentRect, view.frame);
                              }
                              scrollView.contentSize = contentRect.size;
                              [self.view addSubview:scrollView];
                         }
                    } forString:imageUser forCaption:captionString forFullString:imageUserFullString];
               } else {
                    
                    [activity stopAnimating];
                    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                    NSDate *theDate = [dateFormatter dateFromString:[[schoolDay objectAtIndex:index] objectForKey:@"schoolDate"]];
                    [dateFormatter setDateFormat:@"EEEE"];
                    NSString *theString = [dateFormatter stringFromDate:theDate];
                    
                    titleLabel.text = [theString stringByAppendingString:@"'s Picture"];
                    [titleLabel sizeToFit];
                    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 300)];
                    imageView.image = [UIImage imageNamed:@"noPicture@2x.png"];
                    [imageView sizeToFit];
                    imageView.frame = CGRectMake(self.view.frame.size.width / 2 - imageView.frame.size.width / 2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, imageView.frame.size.width, imageView.frame.size.height);
                    [scrollView addSubview:imageView];
                    
                    imageLabelB = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
                    imageLabelB.text = @"NO PICTURE";
                    [imageLabelB sizeToFit];
                    [scrollView addSubview:imageLabelB];
                    
                    removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
                    [removeButton setTitle:@"EDIT PICTURE" forState:UIControlStateNormal];
                    [removeButton sizeToFit];
                    [removeButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
                    removeButton.frame = CGRectMake((self.view.frame.size.width - removeButton.frame.size.width - 10), imageLabelB.frame.origin.y + imageLabelB.frame.size.height + 10, removeButton.frame.size.width, removeButton.frame.size.height);
                    [scrollView addSubview:removeButton];
                    
                         //self.automaticallyAdjustsScrollViewInsets = YES;
                    [scrollView removeFromSuperview];
                    UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 130, 0);
                    scrollView.contentInset = adjustForTabbarInsets;
                    scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
                    CGRect contentRect = CGRectZero;
                    for (UIView *view in scrollView.subviews) {
                         contentRect = CGRectUnion(contentRect, view.frame);
                    }
                    scrollView.contentSize = contentRect.size;
                    [self.view addSubview:scrollView];
               }
          }
     }];
          //self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)keyboardWillHide:(NSNotification *)n
{
     
     scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
     
     keyboardIsShown = NO;
     
     [scrollView removeFromSuperview];
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 130, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
}

- (void)keyboardWillShow:(NSNotification *)n
{
          // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView` if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`, scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.  If we were to resize the `UIScrollView` again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
     if (keyboardIsShown) {
          return;
     }
     
     NSDictionary* userInfo = [n userInfo];
     
          // get the size of the keyboard
     CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
     
          // resize the noteView
     CGRect viewFrame = scrollView.frame;
          // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
     viewFrame.size.height -= (keyboardSize.height - 1);
     
     [UIView beginAnimations:nil context:NULL];
     [UIView setAnimationBeginsFromCurrentState:YES];
     [scrollView setFrame:viewFrame];
     [UIView commitAnimations];
     keyboardIsShown = YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
     if (! hasChanged) {
          hasChanged = true;
          
          separator = [[UIView alloc] initWithFrame:CGRectMake(10, removeButton.frame.origin.y + removeButton.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
          separator.backgroundColor = [UIColor blackColor];
          [scrollView addSubview:separator];
          
          postButton = [UIButton buttonWithType:UIButtonTypeSystem];
          [postButton setTitle:@"SAVE CHANGES" forState:UIControlStateNormal];
          [postButton sizeToFit];
          [postButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
          postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
          [scrollView addSubview:postButton];
          
               //self.automaticallyAdjustsScrollViewInsets = YES;
          [scrollView removeFromSuperview];
          UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 130, 0);
          scrollView.contentInset = adjustForTabbarInsets;
          scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
          CGRect contentRect = CGRectZero;
          for (UIView *view in scrollView.subviews) {
               contentRect = CGRectUnion(contentRect, view.frame);
          }
          scrollView.contentSize = contentRect.size;
          [self.view addSubview:scrollView];
     }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
     
     hasChanged = true;
     
     hasImage = [NSNumber numberWithInt:1];
     
     UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
     imageView.image = [[AppManager getInstance] imageFromImage:chosenImage scaledToWidth:self.view.frame.size.width - 20];
     [imageView sizeToFit];
     imageView.frame = CGRectMake(self.view.frame.size.width / 2 - imageView.frame.size.width / 2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, imageView.frame.size.width, imageView.frame.size.height);
     [scrollView addSubview:imageView];
     
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"h:mm a"];
     NSString *timeString = [formatter stringFromDate:[NSDate date]];
     NSString *myUserString = [[[[PFUser currentUser] objectForKey:@"lastName"] stringByAppendingString:@", "] stringByAppendingString:[[PFUser currentUser] objectForKey:@"firstName"]];
     finalString = [[[@"Posted by " stringByAppendingString:myUserString] stringByAppendingString:@" at "] stringByAppendingString:timeString];
     
     imageLabelB.frame = CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 20);
     imageLabelB.text = finalString;
     [imageLabelB sizeToFit];
     [scrollView addSubview:imageLabelB];
     
     [separatorTwo removeFromSuperview];
     [captionLabel removeFromSuperview];
     
     separatorTwo = [[UIView alloc] initWithFrame:CGRectMake(10, imageLabelB.frame.origin.y + imageLabelB.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separatorTwo.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separatorTwo];
     
     captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, separatorTwo.frame.origin.y + separatorTwo.frame.size.height + 10, self.view.frame.size.width - 20, 20)];
     [captionLabel setFont:[UIFont systemFontOfSize:16]];
     captionLabel.text = @"Caption";
     [captionLabel sizeToFit];
     [scrollView addSubview:captionLabel];
     
     [captionTextView removeFromSuperview];
     
     captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, captionLabel.frame.origin.y + captionLabel.frame.size.height + 10, self.view.frame.size.width - 20, 100)];
     captionTextView.text = @"";
     captionTextView.editable = true;
     captionTextView.scrollEnabled = true;
     [captionTextView setDelegate:self];
     [captionTextView setFont:[UIFont systemFontOfSize:16]];
     captionTextView.layer.borderWidth = 1.0f;
     captionTextView.layer.borderColor = [[UIColor grayColor] CGColor];
     captionTextView.dataDetectorTypes = UIDataDetectorTypeLink;
     [scrollView addSubview:captionTextView];
     
     removeButton.frame = CGRectMake((self.view.frame.size.width - removeButton.frame.size.width - 10), captionTextView.frame.origin.y + captionTextView.frame.size.height + 10, removeButton.frame.size.width, removeButton.frame.size.height);
     
     [separator removeFromSuperview];
     [postButton removeFromSuperview];
     
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, removeButton.frame.origin.y + removeButton.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     postButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [postButton setTitle:@"SAVE CHANGES" forState:UIControlStateNormal];
     [postButton sizeToFit];
     [postButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
     postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
     [scrollView addSubview:postButton];
     
          //self.automaticallyAdjustsScrollViewInsets = YES;
     [scrollView removeFromSuperview];
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 130, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
     
     [picker dismissViewControllerAnimated:YES completion:NULL];
     
}

- (void)removeImage {
     hasChanged = true;
     
     hasImage = false;
     
     imageView.image = [UIImage imageNamed:@"noPicture@2x.png"];
     [imageView sizeToFit];
     imageView.frame = CGRectMake(self.view.frame.size.width / 2 - imageView.frame.size.width / 2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 10, imageView.frame.size.width, imageView.frame.size.height);
     [scrollView addSubview:imageView];
     
     imageLabelB.frame = CGRectMake(10, imageView.frame.origin.y + imageView.frame.size.height + 10, self.view.frame.size.width - 20, 20);
     imageLabelB.text = @"NO IMAGE";
     [imageLabelB sizeToFit];
     [scrollView addSubview:imageLabelB];
     
     [captionLabel removeFromSuperview];
     
     [separatorTwo removeFromSuperview];
     
     [captionTextView removeFromSuperview];
     
     removeButton.frame = CGRectMake((self.view.frame.size.width - removeButton.frame.size.width - 10), imageLabelB.frame.origin.y + imageLabelB.frame.size.height + 10, removeButton.frame.size.width, removeButton.frame.size.height);
     
     [separator removeFromSuperview];
     [postButton removeFromSuperview];
     
     separator = [[UIView alloc] initWithFrame:CGRectMake(10, removeButton.frame.origin.y + removeButton.frame.size.height + 10, self.view.frame.size.width - 20, 1)];
     separator.backgroundColor = [UIColor blackColor];
     [scrollView addSubview:separator];
     
     postButton = [UIButton buttonWithType:UIButtonTypeSystem];
     [postButton setTitle:@"SAVE CHANGES" forState:UIControlStateNormal];
     [postButton sizeToFit];
     [postButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
     postButton.frame = CGRectMake((self.view.frame.size.width - postButton.frame.size.width - 10), separator.frame.origin.y + separator.frame.size.height + 10, postButton.frame.size.width, postButton.frame.size.height);
     [scrollView addSubview:postButton];
     
          //self.automaticallyAdjustsScrollViewInsets = YES;
     [scrollView removeFromSuperview];
     UIEdgeInsets adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 130, 0);
     scrollView.contentInset = adjustForTabbarInsets;
     scrollView.scrollIndicatorInsets = adjustForTabbarInsets;
     CGRect contentRect = CGRectZero;
     for (UIView *view in scrollView.subviews) {
          contentRect = CGRectUnion(contentRect, view.frame);
     }
     scrollView.contentSize = contentRect.size;
     [self.view addSubview:scrollView];
}

- (void)saveImage {
     if ([captionTextView.text isEqual:@""]) {
          checkAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to save this Picture of the Day without a caption?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [checkAlertView show];
     } else {
          postAlertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to save this Picture of the Day? It will be live to all app users." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
          [postAlertView show];
     }
}

- (void)savePictureMethodWithCompletion:(void (^)(NSError *error))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     PFQuery *query = [SchoolDayStructure query];
     [query whereKey:@"schoolDayID" equalTo:self.dayString];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          SchoolDayStructure *structure = (SchoolDayStructure *)object;
          if (hasImage) {
               structure.hasImage = true;
               structure.imageString = captionTextView.text;
               structure.imageUser = [[[[PFUser currentUser] objectForKey:@"lastName"] stringByAppendingString:@", "] stringByAppendingString:[[PFUser currentUser] objectForKey:@"firstName"]];
               structure.imageUserFullString = finalString;
               NSData *data = UIImagePNGRepresentation(imageView.image);
               PFFile *imageFile = [PFFile fileWithData:data];
               structure.imageFile = imageFile;
          } else {
               structure.hasImage = false;
               structure.imageFile = nil;
          }
          [structure saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               if (error) {
                    theError = error;
               }
               dispatch_group_leave(serviceGroup);
          }];
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
          completion(theError);
     });
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
          // the user clicked one of the OK/Cancel buttons
     if (actionSheet == postAlertView) {
          if (buttonIndex == 1) {
               UIActivityIndicatorView *theActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, postButton.frame.origin.y, 30, 30)];
               [postButton removeFromSuperview];
               [theActivity setBackgroundColor:[UIColor clearColor]];
               [theActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
               [scrollView addSubview:theActivity];
               [theActivity startAnimating];
               [self savePictureMethodWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [theActivity stopAnimating];
                         [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         [self.navigationController popViewControllerAnimated:YES];
                    });
               }];
          }
          
     } else if (actionSheet == checkAlertView) {
          if (buttonIndex == 1) {
               UIActivityIndicatorView *theActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, postButton.frame.origin.y, 30, 30)];
               [theActivity setBackgroundColor:[UIColor clearColor]];
               [theActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
               [scrollView addSubview:theActivity];
               [theActivity startAnimating];
               [self savePictureMethodWithCompletion:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [theActivity stopAnimating];
                         [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"reloadHomePage"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         [self.navigationController popViewControllerAnimated:YES];
                    });
               }];
          }
     }
     else {
          if (buttonIndex == 1) {
               [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
          }
     }
}

- (void)editImage {
     UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Edit Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                             @"Select from Camera Roll",
                             @"Take New Picture", 
                             @"Remove Picture",
                             nil];
     [popup showInView:self.view];
}

- (void)getImageDataMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *returnData, NSString *returnString, NSString *returnImageString, NSString *fullReturnString))completion forString:(NSString *)string forCaption:(NSString *)caption forFullString:(NSString *)fullString {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [SchoolDayStructure query];
     [query whereKey:@"schoolDayID" equalTo:schoolDayID];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
          SchoolDayStructure *structure = (SchoolDayStructure *)object;
          PFFile *imageFile = structure.imageFile;
          [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
               theError = error;
               [array addObject:data];
               dispatch_group_leave(serviceGroup);
          }];
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, array, string, caption, fullString);
     });
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
     if (buttonIndex == 0) {
          UIImagePickerController *picker = [[UIImagePickerController alloc] init];
          picker.delegate = self;
          picker.allowsEditing = YES;
          picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
          
          [self presentViewController:picker animated:YES completion:NULL];
     } else if (buttonIndex == 1) {
          UIImagePickerController *picker = [[UIImagePickerController alloc] init];
          picker.delegate = self;
          picker.allowsEditing = YES;
          picker.sourceType = UIImagePickerControllerSourceTypeCamera;
          
          [self presentViewController:picker animated:YES completion:NULL];
     } else if (buttonIndex == 2) {
          if ([hasImage integerValue] == 1) {
               [self removeImage];
          }
     }
}

- (void)getCurrentSchoolDayMethodWithCompletion:(void (^)(NSError *error, NSMutableArray *schoolDay))completion {
     dispatch_group_t serviceGroup = dispatch_group_create();
     dispatch_group_enter(serviceGroup);
     __block NSError *theError;
     NSMutableArray *array = [NSMutableArray array];
     PFQuery *query = [SchoolDayStructure query];
     [query orderByAscending:@"schoolDayID"];
     [query whereKey:@"isActive" equalTo:[NSNumber numberWithInt:1]];
     [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
          theError = error;
          [array addObjectsFromArray:objects];
          dispatch_group_leave(serviceGroup);
     }];
     dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^ {
          NSError *overallError = nil;
          if (theError) {
               overallError = theError;
          }
          completion(overallError, array);
     });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack:(id)sender {
     if (hasChanged) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                          message:@"Are you sure you want to go back? Any changes to today's picture will be lost."
                                                         delegate:self
                                                cancelButtonTitle:@"No"
                                                otherButtonTitles:@"Yes", nil];
          [alert show];
     }
     else {
          [self.navigationController popViewControllerAnimated:YES];
     }
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
