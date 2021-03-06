//
//  twtLoginViewController.h
//  WePeiYang
//
//  Created by Qin Yubo on 14-4-12.
//  Copyright (c) 2014年 Qin Yubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountManager.h"

@interface twtLoginViewController : UIViewController<UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *unameField;
@property (strong, nonatomic) IBOutlet UITextField *passwdField;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property twtLoginType *loginType;

- (IBAction)login:(id)sender;
- (IBAction)cancelLogin:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)textFieldBeginEditing:(id)sender;
- (IBAction)textFieldEndEditing:(id)sender;

@end
