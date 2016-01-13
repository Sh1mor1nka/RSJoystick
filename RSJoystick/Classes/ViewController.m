//
//  ViewController.m
//  RSJoystick
//
//  Created by Roman Simenok on 12/25/15.
//  Copyright © 2015 Roman Simenok. All rights reserved.
//

#import "ViewController.h"
#import "RSJoystick.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet RSJoystick *joystick;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.joystick.continuous = YES;
    self.joystick.wrapAround = YES;
    [self.joystick setThumbColor:[UIColor brownColor]];
}

@end
