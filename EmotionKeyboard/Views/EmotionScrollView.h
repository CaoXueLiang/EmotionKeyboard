//
//  EmotionScrollView.h
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/17.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NormalEmotionCell;
@protocol EmotionScrollViewDelegate <UICollectionViewDelegate>
- (void)emoticonScrollViewDidTapCell:(NormalEmotionCell *)cell;
@end

@interface EmotionScrollView : UICollectionView

@end
