//
//  NormalEmotionCell.h
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/14.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Emoticon;
@interface NormalEmotionCell : UICollectionViewCell
@property (nonatomic, strong) Emoticon *emoticon;
@property (nonatomic, assign) BOOL isDelete; //是否是删除按钮
@end
