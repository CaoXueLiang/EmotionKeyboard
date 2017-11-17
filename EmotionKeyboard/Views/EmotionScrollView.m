//
//  EmotionScrollView.m
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/17.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import "EmotionScrollView.h"
#import "NormalEmotionCell.h"
#import "EmoticonHelper.h"
#import <YYCategories/YYCategories.h>

@implementation EmotionScrollView {
    NSTimeInterval *_touchBeganTime;
    //是否移动
    BOOL _touchMoved;
    //放大镜背景图片
    UIImageView *_magnifier;
    //放大的图片内容
    UIImageView *_magnifierContent;
    __weak NormalEmotionCell *_currentMagnifierCell;
    NSTimer *_backspaceTimer;
}

#pragma mark - Init Menthod
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [UIView new];
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.clipsToBounds = NO;
        self.canCancelContentTouches = NO;
        self.multipleTouchEnabled = NO;
        _magnifier = [[UIImageView alloc]initWithImage:[EmoticonHelper imageNamed:@"emoticon_keyboard_magnifier"]];
        _magnifierContent = [UIImageView new];
        _magnifierContent.size = CGSizeMake(40, 40);
        _magnifierContent.centerX = _magnifier.width / 2.0;
        [_magnifier addSubview:_magnifierContent];
        _magnifier.hidden = YES;
        [self addSubview:_magnifier];
    }
    return self;
}

- (void)dealloc{
    [self endBackspaceTimer];
}

#pragma mark - Event Response
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _touchMoved = NO;
    NormalEmotionCell *cell = [self cellForTouches:touches];
    _currentMagnifierCell = cell;
    [self showMagnifierForCell:_currentMagnifierCell];
    
    if (cell.emotionImageView.image && !cell.isDelete) {
        [[UIDevice currentDevice] playInputClick];
    }
    
    if (cell.isDelete) {
        [self endBackspaceTimer];
        [self performSelector:@selector(startBackspaceTimer) afterDelay:0.5];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _touchMoved = YES;
    if (_currentMagnifierCell && _currentMagnifierCell.isDelete) {
        return;
    }
    NormalEmotionCell *cell = [self cellForTouches:touches];
    if (cell != _currentMagnifierCell) {
        if (!_currentMagnifierCell.isDelete && !cell.isDelete) {
            _currentMagnifierCell = cell;
        }
        [self showMagnifierForCell:cell];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NormalEmotionCell *cell = [self cellForTouches:touches];
    if ((!_currentMagnifierCell.isDelete && cell.emoticon) || (!_touchMoved && cell.isDelete)) {
        if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
            [((id<EmotionScrollViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
        }
    }
    [self hideMagnifier];
    [self endBackspaceTimer];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideMagnifier];
    [self endBackspaceTimer];
}

#pragma mark - Private Menthod
- (NormalEmotionCell *)cellForTouches:(NSSet<UITouch *> *)touches {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if (indexPath) {
        NormalEmotionCell *cell = (id)[self cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)showMagnifierForCell:(NormalEmotionCell *)cell{
    if (cell.isDelete || !cell.emotionImageView.image) {
        [self hideMagnifier];
        return;
    }
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    _magnifier.centerX = CGRectGetMidX(rect);
    _magnifier.bottom = CGRectGetMaxY(rect) - 9;
    _magnifier.hidden = NO;
    
    _magnifierContent.image = cell.emotionImageView.image;
    _magnifierContent.top = 20;
    
    [_magnifierContent.layer removeAllAnimations];
    NSTimeInterval duritation = 0.1;
    [UIView animateWithDuration:duritation delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _magnifierContent.top = 3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duritation delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _magnifierContent.top = 6;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duritation delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _magnifierContent.top = 5;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

- (void)hideMagnifier {
    _magnifier.hidden = YES;
}

- (void)startBackspaceTimer {
    [self endBackspaceTimer];
    @weakify(self);
    _backspaceTimer = [NSTimer timerWithTimeInterval:0.1 block:^(NSTimer *timer) {
        @strongify(self);
        if (!self) return;
        NormalEmotionCell *cell = self->_currentMagnifierCell;
        if (cell.isDelete) {
            if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
                [[UIDevice currentDevice] playInputClick];
                [((id<EmotionScrollViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
            }
        }
    } repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_backspaceTimer forMode:NSRunLoopCommonModes];
}

- (void)endBackspaceTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBackspaceTimer) object:nil];
    [_backspaceTimer invalidate];
    _backspaceTimer = nil;
}

@end

