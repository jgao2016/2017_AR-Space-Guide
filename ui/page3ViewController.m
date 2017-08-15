//
//  page3ViewController.m
//  mrdemo
//
//  Created by Eve M on 8/4/17.
//  Copyright © 2017 Eve M. All rights reserved.
//

#import "page3ViewController.h"

@interface page3ViewController ()

@end

@implementation page3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
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
-(IBAction)myUnwindAction3:(UIStoryboardSegue*)unwindSegue
{
    
}

@end
