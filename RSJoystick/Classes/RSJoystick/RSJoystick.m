/*
	RSJoystick.m
 
	Created by Nathan Day on 7.07.2011 as NDRotator under a MIT-style license.
	Copyright (c) 2011 Nathan Day
 
	Forked by Roman Simenok on 25.12.2015 renamed to RSJoystick under a MIT-style license.
	Copyright (c) 2015 Roman Simenok
 
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
 
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
 
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
*/

#import "RSJoystick.h"

@interface RSJoystick () {
	UIImage *cachedBodyImage,
			*cachedHilightedBodyImage,
			*cachedThumbImage,
			*cachedHilightedThumbImage;
    CGFloat centerCoord;
}

@property (nonatomic) CGFloat touchDownAngle, touchDownYLocation;
@property (nonatomic, readonly) UIImage *cachedBodyImage,
                                        *cachedHilightedBodyImage,
                                        *cachedThumbImage,
                                        *cachedHilightedThumbImage;

@end

@implementation RSJoystick

#pragma mark - Init

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self defaultInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [self defaultInit];
    }
    
    return self;
}

-(void)defaultInit {
    centerCoord = MIN(self.bounds.size.width/2, self.bounds.size.height/2);
    self.radius = 1.0;
    self.minimumValue = 0.0;
    self.maximumValue = 1.0;
    self.minimumDomain = 0.0*M_PI;
    self.maximumDomain = 2.0*M_PI;
    self.continuous = YES;
    self.wrapAround = YES;
    self.thumbColor = [UIColor cyanColor];
    [self setLocation:CGPointMake(centerCoord, centerCoord)];
}

#pragma mark - Getters;

- (CGFloat)radius {
    return _radius;
}

- (CGPoint)cartesianPoint {
    return CGPointMake(cos(self.angle)*self.radius, -sin(self.angle)*self.radius);
}

- (CGPoint)constrainedCartesianPoint {
	CGFloat theRadius = constrainValue(self.radius, 0.0, 1.0);
	return CGPointMake(cos(self.angle)*theRadius, sin(self.angle)*theRadius);
}

- (CGFloat)value {
    return mapValue(self.angle, self.minimumDomain, self.maximumDomain, self.minimumValue, self.maximumValue);
}

#pragma mark - Setters

- (void)setCartesianPoint:(CGPoint)aPoint {
	CGFloat thePreviousAngle = self.angle,
                    theAngle = atan(aPoint.y/aPoint.x);

	if(aPoint.x < 0.0)
		theAngle = M_PI + theAngle;
	else if(aPoint.y < 0)
		theAngle += 2*M_PI;

	while(theAngle - thePreviousAngle > M_PI)
		theAngle -= 2.0*M_PI;

	while(thePreviousAngle - theAngle > M_PI)
		theAngle += 2.0*M_PI;

	self.angle = theAngle;
	self.radius = sqrt(aPoint.x*aPoint.x + aPoint.y*aPoint.y);
}

- (void)setValue:(CGFloat)aValue {
	CGFloat theMinium = self.minimumValue,
           theMaximum = self.maximumValue;

    self.angle = mapValue(constrainValue(self.angle, self.minimumValue, self.maximumDomain), theMinium, theMaximum, self.minimumValue, self.maximumDomain);
}

- (void)setAngle:(CGFloat)anAngle {
	_angle = self.wrapAround != NO
			? wrapValue(anAngle, self.minimumDomain, self.maximumDomain)
			: constrainValue(anAngle, self.minimumDomain, self.maximumDomain);
}

-(void)setThumbColor:(UIColor *)thumbColor {
    _thumbColor = thumbColor;
    [self deleteThumbCache];
}

#pragma mark - Touch Events

- (UIControlEvents)allControlEvents {
    return UIControlEventValueChanged;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)aTouch withEvent:(UIEvent *)anEvent {
	CGPoint thePoint = [aTouch locationInView:self];
	self.touchDownYLocation = thePoint.y;
	self.touchDownAngle = self.angle;
	self.location = thePoint;
    
	if(self.isContinuous)
		[self sendActionsForControlEvents:UIControlEventValueChanged];
    
	[self setNeedsDisplay];
    
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)aTouch withEvent:(UIEvent *)anEvent {
	self.location = [aTouch locationInView:self];
    
	if(self.isContinuous)
		[self sendActionsForControlEvents:UIControlEventValueChanged];
    
	[self setNeedsDisplay];
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)aTouch withEvent:(UIEvent *)anEvent {
	self.location = CGPointMake(centerCoord, centerCoord);
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	[self setNeedsDisplay];
}

- (void)cancelTrackingWithEvent:(UIEvent *)anEvent {
    [self setNeedsDisplay];
}

#pragma mark - UIView

- (void)setFrame:(CGRect)aRect {
	[self deleteThumbCache];
	[self deleteBodyCache];
	[super setFrame:aRect];
}

- (void)setBounds:(CGRect)aRect {
	[self deleteThumbCache];
	[self deleteBodyCache];
	[super setBounds:aRect];
}

- (CGSize)sizeThatFits:(CGSize)aSize {
	return aSize.width < aSize.height
			? CGSizeMake(aSize.width, aSize.width)
			: CGSizeMake(aSize.height, aSize.height);
}

- (void)drawRect:(CGRect)rect {
	if(self.isOpaque) {
		[self.backgroundColor set];
		UIRectFill(rect);
	}

	if(self.state & UIControlStateHighlighted)
		[self.cachedBodyImage drawInRect:self.bounds];
	else
		[self.cachedHilightedBodyImage drawInRect:self.bounds];

	CGPoint theThumbLocation = self.location;
	CGRect theThumbRect = self.thumbRect;
	theThumbRect.origin.x += theThumbLocation.x;
	theThumbRect.origin.y += theThumbLocation.y;
    
	if(self.state & UIControlStateHighlighted)
		[[self cachedHilightedThumbImage] drawInRect:theThumbRect];
	else
		[[self cachedThumbImage] drawInRect:theThumbRect];
}

#pragma mark - methods and properties to call when subclassing <NDRotator>.

- (void)deleteThumbCache {
	cachedThumbImage = nil;
    cachedHilightedThumbImage = nil;
}

- (void)deleteBodyCache {
	cachedBodyImage = nil;
	cachedHilightedBodyImage = nil;
}

#pragma mark - methods to override to change look

- (CGRect)bodyRect {
	CGRect theResult = self.bounds;
	CGRect theBounds = theResult;
	theResult.size.height = floorf(CGRectGetHeight(theResult) * 0.95);
	theResult.size.width = floorf(CGRectGetWidth(theResult) * 0.95);
	theResult.origin.y += ceilf(CGRectGetHeight(theResult) * 0.01);
	theResult.origin.x += ceilf((CGRectGetWidth(theBounds) - CGRectGetWidth(theResult)) * 0.5);
	theResult = shrinkRect(theResult, CGSizeMake(1.0,1.0));
	return largestSquareWithinRect(theResult);
}

- (CGRect)thumbRect {
	CGRect theBounds = self.bodyRect;
	CGFloat theBoundsSize = MIN(CGRectGetWidth(theBounds), CGRectGetHeight(theBounds));
	CGFloat theThumbDiam = theBoundsSize * 0.25;
    
	if(theThumbDiam < 5.0)
		theThumbDiam = 5.0;
	if(theThumbDiam > theBoundsSize * 0.5)
		theThumbDiam = theBoundsSize * 0.5;

	CGFloat theThumbRadius = theThumbDiam/2.0;
	CGRect theThumbBounds = CGRectMake(-theThumbRadius, -theThumbRadius, theThumbDiam, theThumbDiam);
	return shrinkRect(theThumbBounds, CGSizeMake(-1.0,-1.0));
}

static CGGradientRef shadowBodyGradient(CGColorSpaceRef aColorSpace) {
	CGFloat theLocations[] = {0.0, 0.3, 0.6, 1.0};
	CGFloat theComponents[sizeof(theLocations)/sizeof(*theLocations)*4] = { 0.0, 0.0, 0.0, 0.25,  // 0
                                                                            0.0, 0.0, 0.0, 0.125, // 1
                                                                            0.0, 0.0, 0.0, 0.0225, // 1
                                                                            0.0, 0.0, 0.0, 0.0 }; // 2
	return CGGradientCreateWithColorComponents(aColorSpace, theComponents, theLocations, sizeof(theLocations)/sizeof(*theLocations));
}

static CGGradientRef hilightBodyGradient(CGColorSpaceRef aColorSpace, BOOL aHilighted) {
	CGFloat theLocations[] = { 0.0, 0.3, 0.6, 1.0 };
	CGFloat theModifier = aHilighted ? 1.0 : 0.33;
	CGFloat theComponents[sizeof(theLocations)/sizeof(*theLocations)*4] = { 1.0, 1.0, 1.0, 0.0225,  // 0
                                                                            1.0, 1.0, 1.0, 0.33 * theModifier, // 1
                                                                            1.0, 1.0, 1.0, 0.0225, // 1
                                                                            1.0, 1.0, 1.0, 0.0 }; // 2
	return CGGradientCreateWithColorComponents(aColorSpace, theComponents, theLocations, sizeof(theLocations)/sizeof(*theLocations));
}

- (BOOL)drawBodyInRect:(CGRect)aRect hilighted:(BOOL)aHilighted {
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(theContext);

	CGFloat theStartRadius = CGRectGetHeight(aRect)*0.50;
	CGPoint theStartCenter = CGPointMake( CGRectGetMidX(aRect), CGRectGetMidY(aRect)),
					theShadowEndCenter = CGPointMake(theStartCenter.x, theStartCenter.y-0.05*theStartRadius),
					theHilightEndCenter = CGPointMake(theStartCenter.x, theStartCenter.y+0.1*theStartRadius);
	CGColorSpaceRef	theColorSpace = CGColorGetColorSpace(self.backgroundColor.CGColor);
	CGFloat theBodyShadowColorComponents[] = { 0.0, 0.0, 0.0, 0.2 };

	if(aHilighted)
		CGContextSetRGBFillColor(theContext, 0.9, 0.9, 0.9, 1.0);
	else
		CGContextSetRGBFillColor(theContext, 0.8, 0.8, 0.8, 1.0);

	CGContextSetRGBStrokeColor(theContext, 0.75, 0.75, 0.75, 1.0);
	CGContextRef	theBaseContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(theBaseContext);
	CGContextSetShadowWithColor(theBaseContext, CGSizeMake(0.0, theStartRadius*0.05), 2.0, CGColorCreate(theColorSpace, theBodyShadowColorComponents));
	CGContextFillEllipseInRect(theBaseContext, aRect);
	CGContextRestoreGState(theBaseContext);

	CGContextDrawRadialGradient(theContext, hilightBodyGradient(theColorSpace, aHilighted), theStartCenter, theStartRadius, theHilightEndCenter, theStartRadius*0.85, 0.0);
	CGContextDrawRadialGradient(theContext, shadowBodyGradient(theColorSpace), theStartCenter, theStartRadius, theShadowEndCenter, theStartRadius*0.85, 0.0);

	CGContextSetAllowsAntialiasing(theContext, YES);
	CGContextSetRGBStrokeColor(theContext, 0.5, 0.5, 0.5, 1.0 );
	CGContextStrokeEllipseInRect(theContext, aRect);

	CGContextRestoreGState(theContext);
	return YES;
}

static CGGradientRef thumbGradient(UIColor *curentColor) {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [curentColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    UIColor *lighterColor = [UIColor colorWithRed:red-0.3 green:green-0.3 blue:blue-0.3 alpha:1.0];
    
    CGFloat locations[2] = {0.0, 1.0};
    CFArrayRef colors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(id)lighterColor.CGColor,
                                      (id)curentColor.CGColor,
                                      nil];
    
    CGColorSpaceRef colorSpc = CGColorSpaceCreateDeviceRGB();
    return CGGradientCreateWithColors(colorSpc, colors, locations);
}

- (BOOL)drawThumbInRect:(CGRect)aRect hilighted:(BOOL)aHilighted {
	if(!aHilighted) {
		CGContextRef theContext = UIGraphicsGetCurrentContext();
		CGContextSaveGState(theContext);

		CGContextRef theThumbContext = UIGraphicsGetCurrentContext();
		CGContextSaveGState( theThumbContext );

		CGRect theThumbBounds = aRect;
		CGFloat theThumbDiam = CGRectGetWidth(theThumbBounds);
		CGPoint theCenter = CGPointMake(CGRectGetMidX(aRect), CGRectGetMidY(aRect));

		CGContextAddEllipseInRect(theThumbContext, theThumbBounds);
		CGContextClip(theThumbContext);

		CGPoint theStartThumbPoint = CGPointMake(theCenter.x, theCenter.y-theThumbDiam/2.0-theThumbDiam*1.3),
                  theEndThumbPoint = CGPointMake(theCenter.x, theCenter.y+theThumbDiam/2.0-theThumbDiam);
        
        
        
		CGContextDrawRadialGradient(theThumbContext, thumbGradient(self.thumbColor), theStartThumbPoint, 1.3*theThumbDiam, theEndThumbPoint, theThumbDiam, 0.0);

		CGContextRestoreGState(theThumbContext);
		CGContextSetRGBStrokeColor(theContext, 0.3, 0.3, 0.3, 0.15);
		CGContextSetAllowsAntialiasing(theContext, YES);
		CGContextStrokeEllipseInRect(theContext, theThumbBounds);
		CGContextRestoreGState(theContext);
	}
    
	return !aHilighted;
}

#pragma mark - Private

- (CGPoint)location {
	CGRect theBounds = self.bodyRect,
        theThumbRect = self.thumbRect;
	return mapPoint(self.constrainedCartesianPoint, CGRectMake(-1.0, -1.0, 2.0, 2.0), shrinkRect(theBounds, CGSizeMake(CGRectGetWidth(theThumbRect)*0.68,CGRectGetHeight(theThumbRect)*0.68)));
}

- (void)setLocation:(CGPoint)aPoint {
		CGRect theBounds = self.bodyRect,
            theThumbRect = self.thumbRect;
		self.cartesianPoint = mapPoint(aPoint, shrinkRect(theBounds, CGSizeMake(CGRectGetWidth(theThumbRect)*0.68, CGRectGetHeight(theThumbRect)*0.68)), CGRectMake(-1.0, -1.0, 2.0, 2.0 ));
}

- (UIImage *)cachedBodyImage {
    if(!cachedBodyImage) {
		CGRect theBounds = self.bounds;
		UIGraphicsBeginImageContext( theBounds.size );
		if([self drawBodyInRect:self.bodyRect hilighted:NO])
			cachedBodyImage = UIGraphicsGetImageFromCurrentImageContext();
		else
			cachedBodyImage = self.cachedHilightedBodyImage;
		UIGraphicsEndImageContext();
	}
	return cachedBodyImage;
}

- (UIImage *)cachedHilightedBodyImage {
	if(!cachedHilightedBodyImage) {
		CGRect theBounds = self.bounds;
		UIGraphicsBeginImageContext( theBounds.size );
		if([self drawBodyInRect:self.bodyRect hilighted:YES])
			cachedHilightedBodyImage = UIGraphicsGetImageFromCurrentImageContext();
		else
			cachedHilightedBodyImage = self.cachedBodyImage;
		UIGraphicsEndImageContext();
	}
	return cachedHilightedBodyImage;
}

- (UIImage *)cachedThumbImage {
	if(!cachedThumbImage) {
		CGRect theThumbRect = self.thumbRect;
		theThumbRect.origin.x = 0;
		theThumbRect.origin.y = 0;
		UIGraphicsBeginImageContext(theThumbRect.size);
		if([self drawThumbInRect:theThumbRect hilighted:NO])
			cachedThumbImage = UIGraphicsGetImageFromCurrentImageContext();
		else
			cachedThumbImage = self.cachedHilightedThumbImage;
		UIGraphicsEndImageContext();
	}
	return cachedThumbImage;
}

- (UIImage *)cachedHilightedThumbImage {
	if(!cachedHilightedThumbImage) {
		CGRect theThumbRect = self.thumbRect;
		theThumbRect.origin.x = 0;
		theThumbRect.origin.y = 0;
		UIGraphicsBeginImageContext(theThumbRect.size);
		if([self drawThumbInRect:theThumbRect hilighted:YES])
			cachedHilightedThumbImage = UIGraphicsGetImageFromCurrentImageContext();
		else
			cachedHilightedThumbImage = self.cachedThumbImage;
		UIGraphicsEndImageContext();
	}
	return cachedHilightedThumbImage;
}

#pragma mark - Other methods

static CGFloat constrainValue(CGFloat v, CGFloat min, CGFloat max) {
    return v < min ? min : (v > max ? max : v);
}

static CGFloat mapValue(CGFloat v, CGFloat minV, CGFloat maxV, CGFloat minR, CGFloat maxR) {
    return ((v-minV)/(maxV-minV)) * (maxR - minR) + minR;
}

static CGRect shrinkRect(const CGRect v, CGSize s) {
    return CGRectMake(CGRectGetMinX(v)+s.width, CGRectGetMinY(v)+s.height, CGRectGetWidth(v)-2.0*s.width, CGRectGetHeight(v)-2.0*s.height);
}

static CGRect largestSquareWithinRect(const CGRect r) {
    CGFloat theScale = MIN(CGRectGetWidth(r), CGRectGetHeight(r));
    return CGRectMake(CGRectGetMinX(r), CGRectGetMinY(r), theScale, theScale);
}

static CGPoint mapPoint(const CGPoint v, const CGRect rangeV, const CGRect rangeR) {
    return CGPointMake(mapValue(v.x, CGRectGetMinX(rangeV), CGRectGetMaxX(rangeV), CGRectGetMinX(rangeR), CGRectGetMaxX(rangeR)),
                       mapValue(v.y, CGRectGetMinY(rangeV), CGRectGetMaxY(rangeV), CGRectGetMinY(rangeR), CGRectGetMaxY(rangeR)));
}

static inline CGFloat mathMod(CGFloat x, CGFloat y) {
    CGFloat r = fmodf(x, y);
    return r < 0.0 ? r + y : r;
}

static CGFloat wrapValue(CGFloat v, CGFloat min, CGFloat max) {
    return mathMod(v-min, max-min)+min;
}

@end
