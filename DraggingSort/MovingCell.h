//
//  MovingCell.h
//  拖拽排序
//
//  Created by Sekorm on 16/11/10.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MovingDelegate <NSObject>

- (void)longPress:(UILongPressGestureRecognizer *)longPress;

@end

@class MovingItem;

@interface MovingCell : UICollectionViewCell
@property (nonatomic,strong) MovingItem * item;
@property (nonatomic,weak) id<MovingDelegate> delegate;
@end
