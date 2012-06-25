//
//  WCFoldableImageView.m
//  WantedCamera
//
//  Created by Jun Tanaka on 6/22/12.
//  Copyright (c) 2012 Jun Tanaka. All rights reserved.
//

#import "WCFoldableImageView.h"
#import <QuartzCore/CoreAnimation.h>


#pragma mark -
@interface WCFoldableImageViewGradientLayer : CALayer
@property (nonatomic, copy) NSArray *colors;
@end

@implementation WCFoldableImageViewGradientLayer
@synthesize colors = _colors;
- (void)drawInContext:(CGContextRef)ctx
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)self.colors, locations);
    CGPoint startPoint = CGPointMake(self.bounds.size.width / 2, 0);
    CGPoint endPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
    
    CGRect gradientRect = CGRectInset(self.bounds, 1, 0); // anti-alias magic!
    
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, gradientRect);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
- (void)setColors:(NSArray *)colors
{
    _colors = colors;
    [self setNeedsDisplay];
}
@end


#pragma mark -
@interface WCFoldableImageViewCellLayer : CALayer
@property (nonatomic, strong) WCFoldableImageViewGradientLayer *gradientLayer;
@end

@implementation WCFoldableImageViewCellLayer
@synthesize gradientLayer = _gradientLayer;
- (id)init
{
    self = [super init];
    if (self) {
        self.opaque = YES;
        self.gradientLayer = [[WCFoldableImageViewGradientLayer alloc] init];
        [self addSublayer:self.gradientLayer];
    }
    return self;
}
- (void)layoutSublayers
{
    self.gradientLayer.frame = self.bounds;
}
@end


#pragma mark -
@interface WCFoldableImageView () {
    UIImage *_image;
}
@property (nonatomic, strong) NSArray *cellLayers;
@end

@implementation WCFoldableImageView

@synthesize image      = _image;
@synthesize cellLayers = _cellLayers;

- (id)initWithImage:(UIImage *)image 
    numberOfCreases:(NSUInteger)creases 
          direction:(WCFoldableImageViewCreaseDirection)direction
{
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        
        _image = image;
        
        // optimize image for anti-alias
        CGRect imageRect = CGRectMake(0, 0, image.size.width + 2, image.size.height);
        UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, image.scale);
        [image drawInRect:CGRectInset(imageRect, 1, 0)];
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext() , kCGInterpolationHigh);
        UIImage *contentsImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSUInteger numberOfCells = creases + 1;
        NSMutableArray *cellLayers = [[NSMutableArray alloc] initWithCapacity:numberOfCells];
        
        for (int i = 0; i < creases + 1; i++) {
            
            WCFoldableImageViewCellLayer *cellLayer = [[WCFoldableImageViewCellLayer alloc] init];
            cellLayer.contents = (__bridge id)contentsImage.CGImage;
            cellLayer.contentsRect = CGRectMake(0, 1.0 / numberOfCells * i, 1, 1.0 / numberOfCells);
            
            if (i % 2 == 0) {
                cellLayer.anchorPoint = CGPointMake(0.5, 0);
                cellLayer.gradientLayer.colors = [NSArray arrayWithObjects:
                                                  (__bridge id)[UIColor colorWithWhite:0 alpha:0].CGColor, 
                                                  (__bridge id)[UIColor colorWithWhite:0 alpha:0.75].CGColor, 
                                                  nil];
            } else {
                cellLayer.anchorPoint = CGPointMake(0.5, 1);
                cellLayer.gradientLayer.colors = [NSArray arrayWithObjects:
                                                  (__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor, 
                                                  (__bridge id)[UIColor colorWithWhite:0 alpha:0.5].CGColor,
                                                  nil];
            }
            [self.layer addSublayer:cellLayer];
            [cellLayers addObject:cellLayer];
        }
        
        self.cellLayers = cellLayers;
        self.clipsToBounds = YES;
        self.opaque = YES;
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500.0;
        self.layer.sublayerTransform = transform;
        
        [self layoutSublayersOfLayer:self.layer];
    }
    return self;
}

//- (void)layoutSublayersOfLayer:(CALayer *)layer
- (void)layoutSubviews
{
    CGRect cellBounds = CGRectMake(0, 0, self.bounds.size.width + 2, self.image.size.height / [self.cellLayers count]);
    CGFloat rotationAngle = M_PI_2 - asinf(self.bounds.size.height / self.image.size.height);
    float gradientOpacity = 1.0 - self.bounds.size.height / self.image.size.height;
    
    [self.cellLayers enumerateObjectsUsingBlock:^(WCFoldableImageViewCellLayer *cellLayer, NSUInteger index, BOOL *stop) {
        cellLayer.bounds = cellBounds;
        cellLayer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / [self.cellLayers count] * (index + (index % 2)));
        cellLayer.transform = CATransform3DMakeRotation(rotationAngle, (index % 2 == 0) ? -1 : 1, 0, 0);
        cellLayer.gradientLayer.opacity = gradientOpacity;
    }];
}

@end
