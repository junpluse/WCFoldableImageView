//
//  WCViewController.h
//  WCFoldableImageView
//
//  Created by Jun Tanaka on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCFoldableImageView.h"

@interface WCViewController : UIViewController

@property (nonatomic, strong) WCFoldableImageView *foldableImageView;

- (IBAction)sliderValueChanged:(UISlider *)sender;

@end
