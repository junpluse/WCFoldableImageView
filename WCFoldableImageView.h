//
//  WCFoldableImageView.h
//  WantedCamera
//
//  Created by Jun Tanaka on 6/22/12.
//  Copyright (c) 2012 Jun Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    WCFoldableImageViewCreaseDirectionHorizontal,
//    WCFoldableImageViewCreaseDirectionVertical
} WCFoldableImageViewCreaseDirection;


@interface WCFoldableImageView : UIView

- (id)initWithImage:(UIImage *)image 
    numberOfCreases:(NSUInteger)creases 
          direction:(WCFoldableImageViewCreaseDirection)direction; // direction is unimplemented

@property (nonatomic, readonly) UIImage *image;

@end
