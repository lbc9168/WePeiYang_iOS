//
//  GPACalculatorViewController.m
//  WePeiYang
//
//  Created by Qin Yubo on 14-1-28.
//  Copyright (c) 2014年 Qin Yubo. All rights reserved.
//

#import "GPACalculatorViewController.h"

@interface GPACalculatorViewController ()

@end

@implementation GPACalculatorViewController

{
    NSMutableArray *calculatorArray;
}

@synthesize tableView;
@synthesize gpaData;

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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    UIColor *gpaTintColor = [UIColor colorWithRed:255/255.0f green:85/255.0f blue:95/255.0f alpha:1.0f];
    [[UIButton appearance] setTintColor:gpaTintColor];
    [[UINavigationBar appearance] setTintColor:gpaTintColor];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, [data shareInstance].deviceWidth, 64)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
    NSString *backIconPath = [[NSBundle mainBundle]pathForResource:@"backForNav@2x" ofType:@"png"];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageWithContentsOfFile:backIconPath] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openActionSheet)];
    [navigationItem setTitle:@"GPA计算器"];
    [navigationItem setLeftBarButtonItem:backBarBtn];
    [navigationItem setRightBarButtonItem:actionBtn];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    calculatorArray = [[NSMutableArray alloc]initWithObjects: nil];
    for (int i = 0; i < [gpaData count]; i++)
    {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc]init];
        NSDictionary *gpaTmp = [gpaData objectAtIndex:i];
        [tmp setValue:[gpaTmp objectForKey:@"score"] forKey:@"score"];
        [tmp setValue:[gpaTmp objectForKey:@"name"] forKey:@"name"];
        [tmp setValue:[gpaTmp objectForKey:@"credit"] forKey:@"credit"];
        [tmp setValue:[gpaTmp objectForKey:@"term"] forKey:@"term"];
        if ([[tmp objectForKey:@"score"] floatValue] <= 100)
        {
            [tmp setValue:@"YES" forKey:@"selected"];
        }
        else
        {
            [tmp setValue:@"NO" forKey:@"selected"];
        }
        [calculatorArray addObject:tmp];
        
        //用来去除过去重复的科目 这里有Bug
        
        for (NSDictionary *prevDic in calculatorArray)
        {
            if (prevDic != tmp) {
                if ([[prevDic objectForKey:@"name"] isEqualToString:[tmp objectForKey:@"name"]])
                {
                    float prevScore = [[prevDic objectForKey:@"score"] floatValue];
                    float thisScore = [[tmp objectForKey:@"score"] floatValue];
                    if (prevScore < thisScore)
                    {
                        [calculatorArray removeObject:prevDic];
                        break;
                    }
                    else
                    {
                        [calculatorArray removeObject:tmp];
                        break;
                    }
                }
            }
        }
        
    }
}

- (void)openActionSheet {
    
    wpyActionSheet *actionSheet = [[wpyActionSheet alloc]initWithTitle:@"请选择计算规则"];
    
    [actionSheet addButtonWithTitle:@"标准" image:nil type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self calculateGPAwithCalcRule:gpaCalcRuleStandard];
    }];
    
    [actionSheet addButtonWithTitle:@"四分制" image:nil type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self calculateGPAwithCalcRule:gpaCalcRuleFourPt];
    }];
    
    [actionSheet addButtonWithTitle:@"JASSO" image:nil type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self calculateGPAwithCalcRule:gpaCalcRuleJasso];
    }];
    
    [actionSheet addButtonWithTitle:@"改进四分制" image:nil type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self calculateGPAwithCalcRule:gpaCalcRuleImprovedFourPt];
    }];
    
    [actionSheet addButtonWithTitle:@"加拿大4.3分制" image:nil type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        [self calculateGPAwithCalcRule:gpaCalcRuleCanada];
    }];
    
    [actionSheet show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack:(id)sender
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [calculatorArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    //NSUInteger section = [indexPath section];
    
    NSDictionary *tmp = [calculatorArray objectAtIndex:row];
    NSString *name = [tmp objectForKey:@"name"];
    NSString *credit = [tmp objectForKey:@"credit"];
    NSString *score = [tmp objectForKey:@"score"];
    NSString *selected = [tmp objectForKey:@"selected"];
    //NSString *term = [tmp objectForKey:@"term"];
    NSString *cellStr = [NSString stringWithFormat:@"%@, %@学分, %@",name,credit,score];
    cell.textLabel.text = cellStr;
    if ([selected  isEqual: @"YES"])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        NSMutableDictionary *tmp = [calculatorArray objectAtIndex:row];
        [tmp setValue:@"NO" forKey:@"selected"];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        NSMutableDictionary *tmp = [calculatorArray objectAtIndex:row];
        [tmp setValue:@"YES" forKey:@"selected"];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)calculateGPAwithCalcRule:(gpaCalcRule)rule {
    [GPACalculationModel getGPACaluculationResultFromArray:calculatorArray andCalculationRule:rule Success:^(float gpa, NSString *ruleStr) {
        
        NSString *alertStr = [NSString stringWithFormat:@"您的 GPA 为：%.3f\n根据%@计算规则", gpa, ruleStr];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"GPA计算" message:alertStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"请选择希望计入GPA的科目";
}

@end
