//
//  EmoticonInputView.h
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/16.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmoticonInputViewDelegate <NSObject>
@optional
- (void)emoticonInputDidTapText:(NSString *)text;
- (void)emoticonInputDidTapBackspace;
@end

@interface EmoticonInputView : UIView
@property (nonatomic,weak) id<EmoticonInputViewDelegate> delegate;
+ (instancetype)sharedView;
@end
