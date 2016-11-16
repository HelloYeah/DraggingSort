
//
//  MovingCell.m
//  拖拽排序
//
//  Created by Sekorm on 16/11/10.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "MovingCell.h"
#import "MovingItem.h"

@interface MovingCell ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation MovingCell

- (void)awakeFromNib{
    
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = YES;
    //给每个cell添加一个长按手势
    UILongPressGestureRecognizer * longPress =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
}

- (void)setItem:(MovingItem *)item{
    
    _item = item;
    _label.text = item.title;
    self.backgroundColor = item.backGroundColor;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPress:)]) {
        [self.delegate longPress:longPress];
    }
    
}
@end
