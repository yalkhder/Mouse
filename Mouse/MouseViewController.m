//
//  MouseViewController.m
//  Mouse
//
//  Created by Yasser Al-Khder on 2/21/2014.
//  Copyright (c) 2014 Yasser Al-Khder. All rights reserved.
//

#import "MouseViewController.h"

@interface MouseViewController ()

@end

@implementation MouseViewController

- (IBAction)moveMouse:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"pan started");
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"pan changed");
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"pan ended");
    }
}

- (IBAction)leftClick:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        
        NSLog(@"left click");
    }
}


- (IBAction)rightClick:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        
        NSLog(@"right click");
    }
}


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

@end
