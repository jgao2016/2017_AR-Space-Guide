//
//  ViewController.m
//  mrdemo
//
//  Created by Eve M on 8/3/17.
//  Copyright © 2017 Eve M. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backGround;
@property (weak, nonatomic) IBOutlet UIImageView *arIcon;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [_backGround setImage:[UIImage imageNamed:@"Group.png"]];
    [_arIcon setImage:[UIImage imageNamed:@"aricon.png"]];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)myUnwindAction:(UIStoryboardSegue*)unwindSegue
{
    
}

@end
