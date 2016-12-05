//
//   YLDragSortViewController.m
//   
//
//  Created by HelloYeah on 2016/11/30.
//  Copyright © 2016年 YeLiang. All rights reserved.
//
#import "YLDragSortViewController.h"
#import "YLDragSortTool.h"
#import "YLDargSortCell.h"
#import "UIView+Frame.h"
#import "YLDefine.h"

#define kSpaceBetweenSubscribe  4 * SCREEN_WIDTH_RATIO
#define kVerticalSpaceBetweenSubscribe  2 * SCREEN_WIDTH_RATIO
#define kSubscribeHeight  35 * SCREEN_WIDTH_RATIO
#define kContentLeftAndRightSpace  20 * SCREEN_WIDTH_RATIO
#define kTopViewHeight  80 * SCREEN_WIDTH_RATIO

@interface YLDragSortViewController ()<UICollectionViewDataSource,SKDragSortDelegate>

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UICollectionView * dragSortView;
@property (nonatomic,strong) UIView * snapshotView; //截屏得到的view
@property (nonatomic,weak) YLDargSortCell * originalCell;
@property (nonatomic,strong) NSIndexPath * indexPath;
@property (nonatomic,strong) NSIndexPath * nextIndexPath;
@property (nonatomic,strong) UIButton * sortDeleteBtn;

@end

@implementation YLDragSortViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.dragSortView];
    [self.view addSubview:self.topView];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}


#pragma mark - collectionView dataSouce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [YLDragSortTool shareInstance].subscribeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YLDargSortCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YLDargSortCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.subscribe = [YLDragSortTool shareInstance].subscribeArray[indexPath.row];
    return cell;
}

#pragma mark - SKDragSortDelegate

- (void)YLDargSortCellGestureAction:(UIGestureRecognizer *)gestureRecognizer{
    
    //记录上一次手势的位置
    static CGPoint startPoint;
    //触发长按手势的cell
    YLDargSortCell * cell = (YLDargSortCell *)gestureRecognizer.view;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        //开始长按
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            
            [YLDragSortTool shareInstance].isEditing = YES;
            [_sortDeleteBtn setTitle:@"完成" forState:UIControlStateNormal];
            self.dragSortView.scrollEnabled = NO;
        }
        
        if (![YLDragSortTool shareInstance].isEditing) {
            return;
        }
     
        NSArray *cells = [self.dragSortView visibleCells];
        for (YLDargSortCell *cell in cells) {
            [cell showDeleteBtn];
        }
       
        //获取cell的截图
        _snapshotView  = [cell snapshotViewAfterScreenUpdates:YES];
        _snapshotView.center = cell.center;
        [_dragSortView addSubview:_snapshotView];
        _indexPath = [_dragSortView indexPathForCell:cell];
        _originalCell = cell;
        _originalCell.hidden = YES;
        startPoint = [gestureRecognizer locationInView:_dragSortView];
        
        //移动
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        CGFloat tranX = [gestureRecognizer locationOfTouch:0 inView:_dragSortView].x - startPoint.x;
        CGFloat tranY = [gestureRecognizer locationOfTouch:0 inView:_dragSortView].y - startPoint.y;
        
        //设置截图视图位置
        _snapshotView.center = CGPointApplyAffineTransform(_snapshotView.center, CGAffineTransformMakeTranslation(tranX, tranY));
        startPoint = [gestureRecognizer locationOfTouch:0 inView:_dragSortView];
        //计算截图视图和哪个cell相交
        for (UICollectionViewCell *cell in [_dragSortView visibleCells]) {
            //跳过隐藏的cell
            if ([_dragSortView indexPathForCell:cell] == _indexPath || [[_dragSortView indexPathForCell:cell] item] == 0) {
                continue;
            }
            //计算中心距
            CGFloat space = sqrtf(pow(_snapshotView.center.x - cell.center.x, 2) + powf(_snapshotView.center.y - cell.center.y, 2));
            
            //如果相交一半且两个视图Y的绝对值小于高度的一半就移动
            if (space <= _snapshotView.bounds.size.width * 0.5 && (fabs(_snapshotView.center.y - cell.center.y) <= _snapshotView.bounds.size.height * 0.5)) {
                _nextIndexPath = [_dragSortView indexPathForCell:cell];
                if (_nextIndexPath.item > _indexPath.item) {
                    for (NSUInteger i = _indexPath.item; i < _nextIndexPath.item ; i ++) {
                        [[YLDragSortTool shareInstance].subscribeArray exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
                    }
                }else{
                    for (NSUInteger i = _indexPath.item; i > _nextIndexPath.item ; i --) {
                        [[YLDragSortTool shareInstance].subscribeArray exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
                    }
                }
                //移动
                [_dragSortView moveItemAtIndexPath:_indexPath toIndexPath:_nextIndexPath];
                //设置移动后的起始indexPath
                _indexPath = _nextIndexPath;
                break;
            }
        }
        //停止
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [_snapshotView removeFromSuperview];
        _originalCell.hidden = NO;
    }
}

- (void)YLDargSortCellCancelSubscribe:(NSString *)subscribe {
    
   UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"取消订阅%@",subscribe] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}


- (UIView *)topView {

    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTopViewHeight)];
        _topView.backgroundColor = [UIColor whiteColor];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"subscribe_close"] forState:UIControlStateNormal];
        CGFloat btnWH = 35 * SCREEN_WIDTH_RATIO;
        CGFloat topMargin = 15 * SCREEN_WIDTH_RATIO;
        CGFloat rightMargin = 15 * SCREEN_WIDTH_RATIO;
        closeBtn.frame = CGRectMake(SCREEN_WIDTH - btnWH - rightMargin, topMargin, btnWH, btnWH);
        [closeBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:closeBtn];
        
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.font = kFont(13);
        titleLabel.text = @"我的关注";
        [titleLabel sizeToFit];
        titleLabel.textColor = RGBColorMake(110, 110, 110, 1);
        [_topView addSubview:titleLabel];
        titleLabel.centerY = (kTopViewHeight - closeBtn.bottom) * 0.5 + closeBtn.bottom;
        titleLabel.left = kContentLeftAndRightSpace;
        
        UIButton *  finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topView addSubview:finshBtn];
        [finshBtn setTitle:@"排序删除" forState:UIControlStateNormal];
        [finshBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        finshBtn.titleLabel.font = kFont(12);
        finshBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        finshBtn.layer.borderWidth = kLineHeight;
        finshBtn.layer.cornerRadius = 4 * SCREEN_WIDTH_RATIO;
        finshBtn.layer.masksToBounds = YES;
        [finshBtn sizeToFit];
        finshBtn.height = 21 * SCREEN_WIDTH_RATIO;
        finshBtn.width = finshBtn.width + 8 * SCREEN_WIDTH_RATIO;
        finshBtn.right = SCREEN_WIDTH - kContentLeftAndRightSpace;
        finshBtn.centerY = titleLabel.centerY;
        [finshBtn addTarget:self action:@selector(finshClick) forControlEvents:UIControlEventTouchUpInside];
        _sortDeleteBtn = finshBtn;
        
        UIView * bottomLine = [[UIView alloc] initWithFrame:CGRectMake(20 * SCREEN_WIDTH_RATIO, _topView.height - kLineHeight, SCREEN_WIDTH, kLineHeight)];
        bottomLine.backgroundColor = RGBColorMake(110, 110, 110, 1);
        [_topView addSubview:bottomLine];
    }
    return _topView;
}

- (void)finshClick {
    
    [YLDragSortTool shareInstance].isEditing = ![YLDragSortTool shareInstance].isEditing;
    NSString * title = [YLDragSortTool shareInstance].isEditing ? @"完成":@"排序删除";
    
    self.dragSortView.scrollEnabled = ![YLDragSortTool shareInstance].isEditing;
    [_sortDeleteBtn setTitle:title forState:UIControlStateNormal];
   
    [self.dragSortView reloadData];
}

- (void)back {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionView *)dragSortView {
    
    if (!_dragSortView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat width = (SCREEN_WIDTH - 3 * kSpaceBetweenSubscribe - 2 * kContentLeftAndRightSpace )/4 ;
        layout.itemSize = CGSizeMake(width, kSubscribeHeight + 10 * SCREEN_WIDTH_RATIO);
        layout.minimumLineSpacing = kSpaceBetweenSubscribe;
        layout.minimumInteritemSpacing = kVerticalSpaceBetweenSubscribe;
        layout.sectionInset = UIEdgeInsetsMake(kContentLeftAndRightSpace, kContentLeftAndRightSpace, kContentLeftAndRightSpace, kContentLeftAndRightSpace);
        _dragSortView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,kTopViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kTopViewHeight) collectionViewLayout:layout];
        //注册cell
        [_dragSortView registerClass:[YLDargSortCell class] forCellWithReuseIdentifier:@"YLDargSortCell"];
        _dragSortView.dataSource = self;
        _dragSortView.backgroundColor = [UIColor whiteColor];
    }
    return _dragSortView;
}

@end
