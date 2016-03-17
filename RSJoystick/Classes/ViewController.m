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
    [self.joystick addTarget:self action:@selector(positionChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)positionChanged:(RSJoystick *)sender {
    NSLog(@"value: %f", sender.value);
    NSLog(@"radius: %f", sender.radius);
    NSLog(@"angle: %f", sender.angle);
    NSLog(@"cartesian: %@", NSStringFromCGPoint(sender.cartesianPoint));
}

@end
