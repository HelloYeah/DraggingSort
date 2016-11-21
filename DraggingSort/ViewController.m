//
//  ViewController.m
//  拖拽排序
//
//  Created by Sekorm on 16/4/27.
//  Copyright © 2016年 HY. All rights reserved.
//

#import "ViewController.h"
#import "MovingItem.h"
#import "MovingCell.h"
#import "CollectionViewLayout.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height
#define angelToRandian(x)  ((x)/180.0*M_PI)

@interface ViewController ()<UICollectionViewDataSource,UIGestureRecognizerDelegate,UICollectionViewDelegate,MovingDelegate>

@property (nonatomic,strong)UICollectionViewFlowLayout *layout;
@property (nonatomic,strong)NSMutableArray *heightArr;
@property (nonatomic,strong) NSIndexPath * indexPath;
@property (nonatomic,strong) NSIndexPath * nextIndexPath;
@property (nonatomic,strong) NSMutableArray * array;
@property (nonatomic,weak) MovingCell * originalCell;
@property (nonatomic,strong) UIView * snapshotView; //截屏得到的view
@property (nonatomic,strong)  UICollectionView * collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
}


#pragma mark - collectionView dataSouce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    MovingCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.delegate = self;
    MovingItem * item = _array[indexPath.row];
    cell.item = item;
    return cell;
}

#pragma mark - MovingDelegate

     - (void)longPress:(UILongPressGestureRecognizer *)longPress{
        
        //记录上一次手势的位置
        static CGPoint startPoint;
        //触发长按手势的cell
        MovingCell * cell = (MovingCell *)longPress.view;
        
        //开始长按
        if (longPress.state == UIGestureRecognizerStateBegan) {
            
            [self shakeAllCell];
            //获取cell的截图
            _snapshotView  = [cell snapshotViewAfterScreenUpdates:YES];
            _snapshotView.center = cell.center;
            [_collectionView addSubview:_snapshotView];
            _indexPath= [_collectionView indexPathForCell:cell];
            _originalCell = cell;
            _originalCell.hidden = YES;
            startPoint = [longPress locationInView:_collectionView];

        //移动
        }else if (longPress.state == UIGestureRecognizerStateChanged){

        CGFloat tranX = [longPress locationOfTouch:0 inView:_collectionView].x - startPoint.x;
        CGFloat tranY = [longPress locationOfTouch:0 inView:_collectionView].y - startPoint.y;

        //设置截图视图位置
        _snapshotView.center = CGPointApplyAffineTransform(_snapshotView.center, CGAffineTransformMakeTranslation(tranX, tranY));
        startPoint = [longPress locationOfTouch:0 inView:_collectionView];
        //计算截图视图和哪个cell相交
        for (UICollectionViewCell *cell in [_collectionView visibleCells]) {
            //跳过隐藏的cell
            if ([_collectionView indexPathForCell:cell] == _indexPath) {
                continue;
            }
            //计算中心距
            CGFloat space = sqrtf(pow(_snapshotView.center.x - cell.center.x, 2) + powf(_snapshotView.center.y - cell.center.y, 2));

             //如果相交一半且两个视图Y的绝对值小于高度的一半就移动
            if (space <= _snapshotView.bounds.size.width * 0.5 && (fabs(_snapshotView.center.y - cell.center.y) <= _snapshotView.bounds.size.height * 0.5)) {
                _nextIndexPath = [_collectionView indexPathForCell:cell];
                if (_nextIndexPath.item > _indexPath.item) {
                    for (NSUInteger i = _indexPath.item; i < _nextIndexPath.item ; i ++) {
                        [self.array exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
                    }
                }else{
                    for (NSUInteger i = _indexPath.item; i > _nextIndexPath.item ; i --) {
                        [self.array exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
                    }
                }
                //移动
                [_collectionView moveItemAtIndexPath:_indexPath toIndexPath:_nextIndexPath];
                //设置移动后的起始indexPath
                _indexPath = _nextIndexPath;
                break;
            }
        }
     
    //停止
    }else if(longPress.state == UIGestureRecognizerStateEnded){
    
        [self stopShake];
        [_snapshotView removeFromSuperview];
        _originalCell.hidden = NO;
    }
}

#pragma mark - 开始/停止 抖动动画
- (void)shakeAllCell{

    CAKeyframeAnimation* anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.rotation";
    anim.values = @[@(angelToRandian(-2)),@(angelToRandian(2)),@(angelToRandian(-2))];
    anim.repeatCount = MAXFLOAT;
    anim.duration = 0.25;
    NSArray *cells = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in cells) {
        /**如果加了shake动画就不用再加了*/
        if (![cell.layer animationForKey:@"shake"]) {
            [cell.layer addAnimation:anim forKey:@"shake"];
        }
    }
}

- (void)stopShake{

    NSArray *cells = [self.collectionView visibleCells];
    for (UICollectionViewCell *cell in cells) {
        [cell.layer removeAllAnimations];
    }
}

#pragma mark - getter 方法
- (UICollectionView *)collectionView{
    
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight - 20) collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //注册cell
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MovingCell class]) bundle:nil] forCellWithReuseIdentifier:@"cellID"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[CollectionViewLayout alloc] initWithItemsHeightBlock:^CGFloat(NSIndexPath *indexPath) {
            MovingItem * item = self.array[indexPath.item];
            return item.itemWidth;
        }];
        _layout.sectionInset = UIEdgeInsetsMake(100, 0, 10, 0);
    }
    return _layout;
}

- (NSMutableArray *)array{

    if (_array == nil) {
        _array = [[NSMutableArray alloc]initWithCapacity:100];
        for (int i = 0; i < 30; i++) {
            MovingItem * item = [[MovingItem alloc]init];
            item.title = [NSString stringWithFormat:@"第%d个",i];
            item.itemWidth = arc4random()%40+60;
//            item.itemWidth = 100;
            item.backGroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
            [_array addObject:item];
        }
    }
    return _array;
}

@end
