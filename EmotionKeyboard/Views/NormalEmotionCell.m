//
//  NormalEmotionCell.m
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/14.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import "NormalEmotionCell.h"
#import "EmoticonGroup.h"
#import "EmoticonHelper.h"
#import <YYCategories/YYCategories.h>

@implementation NormalEmotionCell
#pragma mark - Init Menthod
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews{
    [self.contentView addSubview:self.emotionImageView];
    self.emotionImageView.frame = CGRectMake(0, 0, 32, 32);
    self.emotionImageView.center = self.contentView.center;
}

- (void)setEmoticon:(Emoticon *)emoticon{
    _emoticon = emoticon;
    self.emotionImageView.image = nil;
    if (_isDelete) {
        self.emotionImageView.image = [EmoticonHelper imageNamed:@"compose_emotion_delete"];
    }else if (_emoticon){
        if (_emoticon.type == EmoticonTypeEmoji) {
            NSNumber *num = [NSNumber numberWithString:_emoticon.code];
            NSString *str = [NSString stringWithUTF32Char:num.unsignedIntValue];
            if (str) {
                //根据字符串表情获得图片
                UIImage *image = [UIImage imageWithEmoji:str size:self.emotionImageView.width];
                self.emotionImageView.image = image;
            }
        }else if (_emoticon.group.groupID && _emoticon.png){
            NSString *pngPath = [[EmoticonHelper emoticonBundle] pathForScaledResource:_emoticon.png ofType:nil inDirectory:_emoticon.group.groupID];
            if (pngPath) {
                self.emotionImageView.image = [UIImage imageWithContentsOfFile:pngPath];
            }
        }
    }
}

#pragma mark - Setter && Getter
- (UIImageView *)emotionImageView{
    if (!_emotionImageView) {
        _emotionImageView = [[UIImageView alloc]init];
        _emotionImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _emotionImageView;
}

@end

