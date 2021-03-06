//
//  HiringDetailViewController.m
//  WePeiYang
//
//  Created by Qin Yubo on 14-5-9.
//  Copyright (c) 2014年 Qin Yubo. All rights reserved.
//

#import "HiringDetailViewController.h"
#import "ContentDataManager.h"
#import "data.h"
#import "MsgDisplay.h"
#import "CalendarEventActivity.h"

@interface HiringDetailViewController ()

@end

@implementation HiringDetailViewController

@synthesize webView;
@synthesize hiringCorp;
@synthesize hiringDate;
@synthesize hiringId;
@synthesize hiringPlace;
@synthesize hiringTime;
@synthesize hiringTitle;

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
    self.title = hiringTitle;
    UIBarButtonItem *share = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareInfo)];
    [self.navigationItem setRightBarButtonItem:share];
    
    NSDictionary *parameters = @{@"ctype":@"fair",
                                 @"index":hiringId,
                                 @"platform":@"ios",
                                 @"version":[data shareInstance].appVersion};
    [ContentDataManager getDetailDataWithParameters:parameters success:^(id responseObject) {
        [self processContentDic:responseObject];
    }failure:^(NSString *error) {
        [MsgDisplay showErrorMsg:error];
    }];
}

- (void)processContentDic:(NSDictionary *)dic
{
    [webView loadHTMLString:[dic objectForKey:@"content"] baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareInfo
{
    NSString *shareStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",hiringTitle,hiringCorp,hiringDate,hiringTime,hiringPlace];
    
    
    NSDictionary *shareDic = @{@"title": hiringTitle,
                               @"corp": hiringCorp,
                               @"date": hiringDate,
                               @"time": hiringTime,
                               @"place": hiringPlace};
    NSData *shareData = [NSKeyedArchiver archivedDataWithRootObject:shareDic];
    
    NSArray *activityItems = @[shareStr, shareData];
    CalendarEventActivity *calendarActivity = [[CalendarEventActivity alloc]init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities: @[calendarActivity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
