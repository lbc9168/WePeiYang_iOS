//
//  twtLoginViewController.m
//  WePeiYang
//
//  Created by Qin Yubo on 14-4-12.
//  Copyright (c) 2014年 Qin Yubo. All rights reserved.
//

#import "twtLoginViewController.h"
#import "GPAViewController.h"
//#import "AFNetworking.h"
#import "data.h"
#import "UIButton+Bootstrap.h"
//#import "wpyEncryption.h"
#import "GuideViewController.h"
#import "SVProgressHUD.h"
//#import "twtSecretKeys.h"
//#import "twtAPIs.h"
#import <POP/POP.h>

#define DEVICE_IS_IPHONE5 (fabs((double)[UIScreen mainScreen].bounds.size.height - (double)568) < DBL_EPSILON)

@interface twtLoginViewController ()

@end

@implementation twtLoginViewController

{
    UIAlertView *successAlert;
}

@synthesize unameField;
@synthesize passwdField;
@synthesize loginType;
@synthesize loginBtn;
@synthesize cancelBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIColor *color = [UIColor colorWithWhite:0.9 alpha:1.0];
    unameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入天外天账号" attributes:@{NSForegroundColorAttributeName: color}];
    passwdField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName: color}];
    [[UITextField appearance]setTintColor:color];
    self.view.backgroundColor = [UIColor colorWithRed:49/255.0f green:154/255.0f blue:207/255.0f alpha:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (IBAction)login:(id)sender
{
    [SVProgressHUD showWithStatus:@"登录中..." maskType:SVProgressHUDMaskTypeBlack];
    [loginBtn setUserInteractionEnabled:NO];
    if ([self moved])
    {
        [self adjustViewAnimation];
    }
    [unameField resignFirstResponder];
    [passwdField resignFirstResponder];
    NSString *uname = [unameField text];
    NSString *passwd = [passwdField text];
    if ([uname isEqualToString:@""] || [passwd isEqualToString:@""])
    {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"用户名或密码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSDictionary *parameters = @{@"twtuname":uname,
                                     @"twtpasswd":passwd,
                                     @"platform":@"ios",
                                     @"version":[data shareInstance].appVersion};
        [AccountManager loginWithParameters:parameters andType:loginType Success:^() {
            [SVProgressHUD dismiss];
            
            if (loginType == nil) {
                loginType = twtLoginTypeNormal;
            }
            
            if (loginType == twtLoginTypeNormal) {
                successAlert = [[UIAlertView alloc]initWithTitle:@"成功" message:@"登录成功！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [successAlert show];
            } else if (loginType == twtLoginTypeGPA) {
                [data shareInstance].gpaLoginStatus = @"Changed";
                successAlert = [[UIAlertView alloc]initWithTitle:@"成功" message:@"登录成功！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [successAlert show];
            } else if (loginType == twtLoginTypeLibrary) {
                [data shareInstance].libLogin = @"Changed";
                successAlert = [[UIAlertView alloc]initWithTitle:@"成功" message:@"登录成功！\n图书馆系统加载速度较慢\n请耐心等待哦" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [successAlert show];
            }
            [loginBtn setUserInteractionEnabled:YES];
            
        } Failure:^(NSInteger statusCode, NSString *errorStr) {
            [SVProgressHUD dismiss];
            
            if (statusCode == 401) {
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"出错" message:@"账号或密码错误哦QAQ" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [errorAlert show];
            } else {
                [SVProgressHUD showErrorWithStatus:errorStr];
            }
            
        }];
    }
    [loginBtn setUserInteractionEnabled:YES];
}

- (IBAction)cancelLogin:(id)sender
{
    UIViewController *presentingVC = self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{
        if ([presentingVC isKindOfClass:[GuideViewController class]]) {
            [presentingVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == successAlert)
    {
        UIViewController *presentingVC = self.presentingViewController;
        [self dismissViewControllerAnimated:YES completion:^{
            if ([presentingVC isKindOfClass:[GuideViewController class]]) {
                [presentingVC dismissViewControllerAnimated:YES completion:nil];
            } else if ([presentingVC isKindOfClass:[GPAViewController class]]) {
                //
            }
        }];
    }
}

- (IBAction)backgroundTapped:(id)sender
{
    [unameField resignFirstResponder];
    [passwdField resignFirstResponder];
    if ([self moved])
    {
        [self adjustViewAnimation];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)textFieldBeginEditing:(id)sender
{
    if (![self moved] && self.view.frame.size.width == 320) {
        [self adjustViewAnimation];
    }
}

- (IBAction)textFieldEndEditing:(id)sender
{
    if ([self moved] && self.view.frame.size.width == 320) {
        [self adjustViewAnimation];
    }
}

- (void)adjustViewAnimation {
    POPBasicAnimation *viewAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    CGPoint point = self.view.center;
    CGFloat halfHeight = 0.5*[[UIScreen mainScreen] bounds].size.height;
    if ([self moved]) {
        viewAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(point.x, halfHeight)];
    } else {
        viewAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(point.x, halfHeight - 80)];
    }
    [self.view.layer pop_addAnimation:viewAnim forKey:@"viewAnimation"];
}

- (BOOL)moved {
    CGPoint point = self.view.center;
    CGFloat halfHeight = 0.5*[[UIScreen mainScreen] bounds].size.height;
    if (point.y == halfHeight) {
        return NO;
    } else {
        return YES;
    }
}


@end
