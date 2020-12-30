//
//  ANSViewController.m
//  AnalysysDataBase
//
//  Created by xiaoxu1234 on 12/29/2020.
//  Copyright (c) 2020 xiaoxu1234. All rights reserved.
//

#import "ANSViewController.h"
#import <AnalysysDataBase/AnalysysDataBase.h>
@interface ANSViewController ()
- (IBAction)insertAction:(id)sender;
- (IBAction)selectAction:(id)sender;

@end

@implementation ANSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectAction:(id)sender {
    [[AnalysysDataBase sharedManager] selectLogFinshBlock:^(NSArray *arr) {
        NSLog(@"%@",arr);
    }];
}

- (IBAction)insertAction:(id)sender {
    [[AnalysysDataBase sharedManager] insertLog:@"aaaaaaaaaa" success:^(BOOL isSuccess) {
        //
    }];
}
@end
