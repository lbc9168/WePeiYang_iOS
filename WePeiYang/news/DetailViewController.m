//
//  DetailViewController.m
//  News
//
//  Created by Qin Yubo on 13-10-13.
//  Copyright (c) 2013年 Qin Yubo. All rights reserved.
//

#import "DetailViewController.h"
#import "data.h"
#import "Social/Social.h"
#import "AFNetworking.h"
#import "wpyStringProcessor.h"
#import "SVProgressHUD.h"
#import "AHKActionSheet.h"
#import "WePeiYang-Swift.h"

#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)

@interface DetailViewController ()

@end

@implementation DetailViewController

{
    NSString *detailContent;
}

@synthesize webView;
@synthesize detailId;
@synthesize detailTitle;

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
    [self.navigationController setToolbarHidden:YES animated:YES];
    //detailTitle = [data shareInstance].newsTitle;
    //detailId = [data shareInstance].newsId;
    self.title = detailTitle;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIBarButtonItem *openInSafari = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(optionActionSheet:)];
    self.navigationItem.rightBarButtonItem = openInSafari;
    
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeBlack];
    
    NSString *url = @"http://push-mobile.twtapps.net/content/detail";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"ctype":@"news",
                                 @"index":detailId,
                                 @"platform":@"ios",
                                 @"version":[data shareInstance].appVersion};
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self processDetailData:responseObject];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"获取新闻失败T^T"];
    }];
}

- (void)processDetailData:(NSDictionary *)contentDic
{
    NSURL *baseURL = [[NSURL alloc]initWithString:@"http://mynews.twtstudio.com/newspic/picture/"];
    if ([contentDic count]>0)
    {
        detailContent = [contentDic objectForKey:@"content"];
    }
    
    [self.webView loadHTMLString:[wpyStringProcessor convertToBootstrapHTMLWithContent:detailContent] baseURL:baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)optionActionSheet:(id)sender
{
    wpyActionSheet *actionSheet = [[wpyActionSheet alloc]initWithTitle:@"更多"];
    
    [actionSheet addButtonWithTitle:@"分享" image:[UIImage imageNamed: @"shareInSheet.png"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self share];
    }];
    
    [actionSheet addButtonWithTitle:@"收藏" image:[UIImage imageNamed: @"addToFav.png"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self addToCollection];
    }];
    
    [actionSheet addButtonWithTitle:@"在 Safari 中打开" image:[UIImage imageNamed: @"openInSafari.png"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self openInSafari];
    }];
    
    [actionSheet show];
}

- (void)openInSafari
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.twt.edu.cn/?c=default&a=pernews&id=%@", self.detailId]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)share
{
    NSArray *activityItems;
    NSString *shareString = [[NSString alloc]initWithFormat:@"%@",self.detailTitle];
    NSURL *shareURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://news.twt.edu.cn/?c=default&a=pernews&id=%@",self.detailId]];
    activityItems = @[shareString, shareURL];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)addToCollection
{
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"collectionData"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:plistPath])
    {
        [fileManager createFileAtPath:plistPath contents:nil attributes:nil];
    }
    NSMutableDictionary *collectionDic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    if (collectionDic == nil)
    {
        collectionDic = [[NSMutableDictionary alloc]init];
    }
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    [newDic setObject:detailTitle forKey:@"title"];
    [newDic setObject:detailContent forKey:@"content"];
    [newDic setObject:detailId forKey:@"id"];
    
    [collectionDic setObject:newDic forKey:detailTitle];
    [collectionDic writeToFile:plistPath atomically:YES];
    
    [SVProgressHUD showSuccessWithStatus:@"新闻收藏成功！"];
}

@end
