//
//  CollectionViewLayout.h
//
//  Created by mac on 16/9/14.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef CGFloat (^WidthBlock)(NSIndexPath *indexPath);

@interface CollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic,assign)CGFloat colMargin;

@property (nonatomic,assign)CGFloat rolMargin;

@property (nonatomic,assign) CGFloat  rightSpace;

@property (nonatomic,assign) CGFloat  bottomSpace;
//单元格的宽度
@property (nonatomic,assign)CGFloat colWidth;

@property (nonatomic,strong)WidthBlock widthBlock;

-(instancetype)initWithItemsWidthBlock:(WidthBlock)block;




@end
