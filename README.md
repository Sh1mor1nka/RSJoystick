# RSJoystick
RSJoystick is joystick control for iOS.

![Demo GIF](http://i.imgur.com/3XhIMDR.gif)

Here is values you can get from joystick:
``` Objective-C
-(void)positionChanged:(RSJoystick *)sender {
    NSLog(@"value: %f", sender.value);
    NSLog(@"radius: %f", sender.radius);
    NSLog(@"angle: %f", sender.angle);
    NSLog(@"cartesian: %@", NSStringFromCGPoint(sender.cartesianPoint));
}
```

## License
RSJoystick is licensed under the terms of the MIT license. Please see the [LICENSE](LICENSE) file for full details.
