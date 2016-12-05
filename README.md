# DraggingSort

###导读
>拖拽排序是新闻类的App可以说是必有的交互设计，如今日头条，网易新闻等。拖拽排序是一个交互体验非常好的设计，简单，方便。

####今日头条的拖拽排序界面
![今日头条的拖拽排序界面.png](http://upload-images.jianshu.io/upload_images/1338042-7d5fa67d9b03b5a9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


####我实现的长按拖拽排序效果
![长按拖拽排序.gif](http://upload-images.jianshu.io/upload_images/1338042-dd15e90dd9e752fc.gif?imageMogr2/auto-orient/strip)

####实现方案

1.给CollectionViewCell添加一个长按手势，通过协议把手势传递到collectionView所在的控制器中。
    - (void)awakeFromNib{
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        //给每个cell添加一个长按手势
        UILongPressGestureRecognizer * longPress =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        longPress.delegate = self;
        [self addGestureRecognizer:longPress];
    }

    - (void)longPress:(UILongPressGestureRecognizer *)longPress{
        if (self.delegate && [self.delegate respondsToSelector:@selector(longPress:)]) {
            [self.delegate longPress:longPress];
        }
    }

2.开始长按时对cell进行截图，并隐藏cell。

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
        }

3、在手势移动的时候，移动截图视图，用遍历的方法求出截图移动到哪个cell的位置，再调用系统的api交换这个cell和隐藏cell的位置，并且数据源中的数据也需要调整顺序

        //手势移动的时候
        else if (longPress.state == UIGestureRecognizerStateChanged){
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
4.手势停止时，移除截图的view，显示隐藏cell

    //手势停止时
    }else if(longPress.state == UIGestureRecognizerStateEnded){
        [self stopShake];
        [_snapshotView removeFromSuperview];
        _originalCell.hidden = NO;
    }

####其他
代码还可以进一步封装，写一个数据管理类dataTool，dataTool作为collectionView的数据源，所有的数据源方法都写到dataTool类中。手势的代理方法也在里面实现，这样控制器会简洁很多，控制器就不需要关注拖拽排序的具体逻辑了。大家有空可以自己写写看，也许你们有更好的处理方案，可以评论交流一下。
github地址：https://github.com/HelloYeah/DraggingSort
