//
//  MovingItem.h
//  拖拽排序
//
//  Created by Sekorm on 16/11/10.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovingItem : NSObject

@property (nonatomic,copy) NSString * title;
@property (nonatomic,strong)  UIColor *backGroundColor;
@property (nonatomic,assign) CGFloat  itemWidth;

@end
