//
//  SKDragSortTool.m
//   
//
//  Created by HelloYeah on 2016/11/30.
//  Copyright © 2016年 YeLiang. All rights reserved.
//

#import "YLDragSortTool.h"

@implementation YLDragSortTool
static YLDragSortTool *DragSortTool = nil;

+ (instancetype)shareInstance
{
    @synchronized (self) {
        if (DragSortTool == nil) {
            DragSortTool = [[self alloc] init];
        }
    }
    
    return DragSortTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (DragSortTool == nil) {
            DragSortTool = [super allocWithZone:zone];
        }
    }
    return DragSortTool;
}

- (id)copy
{
    return DragSortTool;
}

- (id)mutableCopy{
    return DragSortTool;
}

- (NSMutableArray *)subscribeArray {

    if (!_subscribeArray) {
        
        _subscribeArray = [@[@"推荐",@"视频",@"军事",@"娱乐",@"问答",@"娱乐",@"汽车",@"段子",@"趣图",@"财经",@"热点",@"房产",@"社会",@"数码",@"美女",@"数码",@"文化",@"美文",@"星座",@"旅游",@"视频",@"军事",@"娱乐",@"问答",@"娱乐",@"汽车",@"段子",@"趣图",@"财经",@"热点",@"房产",@"社会",@"数码",@"美女",@"数码",@"文化",@"美文",@"星座",@"旅游"] mutableCopy];
    }
    return _subscribeArray;
}


@end
