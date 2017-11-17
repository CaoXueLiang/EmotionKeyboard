//
//  CommentViewController.m
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/17.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import "CommentViewController.h"
#import <YYCategories/YYCategories.h>
#import <YYText/YYText.h>
#import <YYKeyboardManager/YYKeyboardManager.h>
#import "EmoticonInputView.h"
#import "EmoticonHelper.h"
#import  <YYModel/YYModel.h>

#define kToolbarHeight 46
@interface CommentViewController ()<EmoticonInputViewDelegate,YYTextKeyboardObserver,YYTextViewDelegate>
@property (nonatomic,strong) YYTextView *textView;
@property (nonatomic,strong) UIView *toolbar;
@property (nonatomic,strong) UIButton *pictureButton;
@property (nonatomic,strong) UIButton *atButton;
@property (nonatomic,strong) UIButton *topicButton;
@property (nonatomic,strong) UIButton *emoticonButton;
@property (nonatomic,strong) UIButton *addButton;
@end

@implementation CommentViewController
#pragma mark - Init Menthod
- (void)dealloc{
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"评论";
    [self _setNavigation];
    [self _intTextView];
    [self _initToolbar];
    
    [_textView becomeFirstResponder];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
}

- (void)_setNavigation{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(_cancel)];
    [button setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                     NSForegroundColorAttributeName : UIColorHex(4c4c4c)} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = button;
}

- (void)_intTextView{
    if (_textView) {
        return;
    }
    _textView = [YYTextView new];
    _textView.size = CGSizeMake(self.view.width, self.view.height);
    _textView.textContainerInset = UIEdgeInsetsMake(12, 16, 12, 16);
    _textView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarHeight, 0);
    _textView.extraAccessoryViewHeight = kToolbarHeight;
    _textView.showsVerticalScrollIndicator = NO;
    _textView.alwaysBounceVertical = YES;
    _textView.allowsCopyAttributedString = NO;
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.delegate = self;
    _textView.inputAccessoryView = [UIView new];
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:@"写评论..."];
    atr.yy_color = UIColorHex(b4b4b4);
    atr.yy_font = [UIFont systemFontOfSize:17];
    _textView.placeholderAttributedText = atr;
    [self.view addSubview:_textView];
}

- (void)_initToolbar{
    if (_toolbar) {
        return;
    }
    _toolbar = [UIView new];
    _toolbar.size = CGSizeMake(self.view.width, kToolbarHeight);
    _toolbar.backgroundColor = UIColorHex(F9F9F9);
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColorHex(BFBFBF);
    line.width = _toolbar.width;
    line.height = CGFloatFromPixel(1);
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_toolbar addSubview:line];
    
    _pictureButton = [self _toolbarButtonWithImage:@"compose_toolbar_picture"
                                                highlight:@"compose_toolbar_picture_highlighted"];
    _atButton = [self _toolbarButtonWithImage:@"compose_mentionbutton_background"
                                           highlight:@"compose_mentionbutton_background_highlighted"];
    _topicButton = [self _toolbarButtonWithImage:@"compose_trendbutton_background"
                                              highlight:@"compose_trendbutton_background_highlighted"];
    _emoticonButton = [self _toolbarButtonWithImage:@"compose_emoticonbutton_background"
                                                 highlight:@"compose_emoticonbutton_background_highlighted"];
    _addButton = [self _toolbarButtonWithImage:@"message_add_background"
                                              highlight:@"message_add_background_highlighted"];
    
    CGFloat one = _toolbar.width / 5;
    _pictureButton.centerX = one * 0.5;
    _atButton.centerX = one * 1.5;
    _topicButton.centerX = one * 2.5;
    _emoticonButton.centerX = one * 3.5;
    _addButton.centerX = one * 4.5;
    
    _toolbar.bottom = self.view.height;
    [self.view addSubview:_toolbar];
}

- (UIButton *)_toolbarButtonWithImage:(NSString *)imageName highlight:(NSString *)highlightImageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.size = CGSizeMake(46, 46);
    [button setImage:[EmoticonHelper imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[EmoticonHelper imageNamed:highlightImageName] forState:UIControlStateHighlighted];
    button.centerY = 46 / 2;
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [button addTarget:self action:@selector(_buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar addSubview:button];
    return button;
}

#pragma mark - Event Response
- (void)_cancel{
    [self.view endEditing:YES];
    if (_dissMiss) {
        _dissMiss();
    }
}

- (void)_buttonClicked:(UIButton *)button{
    if (button == _emoticonButton) {
        if (_textView.inputView) {
            _textView.inputView = nil;
            [_textView reloadInputViews];
            [_textView becomeFirstResponder];
            
            [_emoticonButton setImage:[EmoticonHelper imageNamed:@"compose_emoticonbutton_background"] forState:UIControlStateNormal];
            [_emoticonButton setImage:[EmoticonHelper imageNamed:@"compose_emoticonbutton_background_highlighted"] forState:UIControlStateHighlighted];
        } else {
            EmoticonInputView *v = [EmoticonInputView sharedView];
            v.delegate = self;
            _textView.inputView = v;
            [_textView reloadInputViews];
            [_textView becomeFirstResponder];
            [_emoticonButton setImage:[EmoticonHelper imageNamed:@"compose_keyboardbutton_background"] forState:UIControlStateNormal];
            [_emoticonButton setImage:[EmoticonHelper imageNamed:@"compose_keyboardbutton_background_highlighted"] forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition {
    CGRect toFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    if (transition.animationDuration == 0) {
        _toolbar.bottom = CGRectGetMinY(toFrame);
    } else {
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption | UIViewAnimationOptionBeginFromCurrentState animations:^{
            _toolbar.bottom = CGRectGetMinY(toFrame);
        } completion:NULL];
    }
}

#pragma mark - EmoticonInputViewDelegate
- (void)emoticonInputDidTapText:(NSString *)text{
    if (text && text.length > 0) {
        [_textView replaceRange:_textView.selectedTextRange withText:text];
    }
}

- (void)emoticonInputDidTapBackspace{
    [_textView deleteBackward];
}

@end

