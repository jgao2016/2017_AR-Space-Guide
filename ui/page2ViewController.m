//
//  page2ViewController.m
//  mrdemo
//
//  Created by Eve M on 8/4/17.
//  Copyright © 2017 Eve M. All rights reserved.
//

#import "page2ViewController.h"

@interface page2ViewController ()

@end

@implementation page2ViewController

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
-(IBAction)myUnwindAction2:(UIStoryboardSegue*)unwindSegue
{
    
}

@end
