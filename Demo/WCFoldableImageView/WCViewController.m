//
//  WCViewController.m
//  WCFoldableImageView
//
//  Created by Jun Tanaka on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCViewController.h"
#import <QuartzCore/CoreAnimation.h>

@implementation WCViewController

@synthesize foldableImageView = _foldableImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"Image"];
    
    self.foldableImageView = [[WCFoldableImageView alloc] initWithImage:image numberOfCreases:9 direction:WCFoldableImageViewCreaseDirectionHorizontal];
        
    [self.view addSubview:self.foldableImageView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.foldableImageView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, sender.value);
    [self.foldableImageView layoutSubviews];
    
    [CATransaction commit];
}

@end
