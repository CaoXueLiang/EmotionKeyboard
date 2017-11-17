//
//  EmoticonInputView.m
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/16.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import "EmoticonInputView.h"
#import "EmoticonGroup.h"
#import <YYCategories/YYCategories.h>
#import "EmoticonHelper.h"
#import "NormalEmotionCell.h"
#import "EmotionScrollView.h"

static const NSInteger kViewHeight = 216;
static const NSInteger kToolbarHeight = 37;
static const NSInteger kOneEmoticonHeight = 50;
static const NSInteger kOnePageCount = 20;

@interface EmoticonInputView()<UICollectionViewDelegate,UICollectionViewDataSource,EmotionScrollViewDelegate>
@property (nonatomic,strong) EmotionScrollView *myCollection;
@property (nonatomic,strong) NSArray<UIButton *> *toolbarButtons;
@property (nonatomic,strong) UIView *pageControl;
/// 所有的表情数组
@property (nonatomic,strong) NSArray<EmoticonGroup *> *emoticonGroups;
/// 每组表情page起点索引
@property (nonatomic,strong) NSArray<NSNumber *> *emoticonGroupPageIndexs;
/// 每组表情有几页
@property (nonatomic,strong) NSArray<NSNumber *> *emoticonGroupPageCounts;
@property (nonatomic,assign) NSInteger emoticonGroupTotalPageCount;
@property (nonatomic,assign) NSInteger currentPageIndex;
@end

@implementation EmoticonInputView
#pragma mark - Init Menthod
+ (instancetype)sharedView {
    static EmoticonInputView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [self new];
    });
    return v;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreenWidth, kViewHeight);
        self.backgroundColor = UIColorHex(f9f9f9);
        [self _initEmotionGroup];
        [self _initTopLine];
        [self _initCollectionView];
        [self _initToolbar];
    }
    return self;
}

- (void)_initEmotionGroup{
    _emoticonGroups = [EmoticonHelper emoticonGroups];
    /// 计算每一页起点的索引
    NSMutableArray *indexs = [NSMutableArray new];
    NSUInteger index = 0;
    for (EmoticonGroup *emotionGroup in _emoticonGroups) {
        [indexs addObject:@(index)];
        NSUInteger count = ceil(emotionGroup.emoticons.count / (float)kOnePageCount);
        if (count == 0) count = 1;
        index += count;
    }
    _emoticonGroupPageIndexs = [indexs mutableCopy];
    
    /// 计算每一页的表情的个数
    NSMutableArray *pageCounts = [NSMutableArray new];
    _emoticonGroupTotalPageCount = 0;
    for (EmoticonGroup *emotionGroup in _emoticonGroups) {
        [indexs addObject:@(index)];
        NSUInteger pageCount = ceil(emotionGroup.emoticons.count / (float)kOnePageCount);
        if (pageCount == 0) pageCount = 1;
        [pageCounts addObject:@(pageCount)];
        _emoticonGroupTotalPageCount += pageCount;
    }
    _emoticonGroupPageCounts = pageCounts;
}

- (void)_initTopLine{
    UIView *line = [UIView new];
    line.width = self.width;
    line.height = CGFloatFromPixel(1);
    line.backgroundColor = UIColorHex(bfbfbf);
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:line];
}

- (void)_initCollectionView{
    CGFloat itermWidth = (kScreenWidth - 10 *2) / 7.0;
    itermWidth = CGFloatPixelRound(itermWidth);
    CGFloat padding = (kScreenWidth - 7 *itermWidth) / 2.0;
    CGFloat paddingLeft = CGFloatPixelRound(padding);
    CGFloat paddingRight = kScreenWidth - 7 *itermWidth - paddingLeft;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itermWidth, kOneEmoticonHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, paddingLeft, 0, paddingRight);
    
    _myCollection = [[EmotionScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kOneEmoticonHeight *3.0) collectionViewLayout:layout];
    [_myCollection registerClass:[NormalEmotionCell class] forCellWithReuseIdentifier:@"NormalEmotionCell"];
    _myCollection.delegate = self;
    _myCollection.dataSource = self;
    _myCollection.top = 5;
    [self addSubview:_myCollection];
    
    _pageControl = [UIView new];
    _pageControl.size = CGSizeMake(kScreenWidth, 20);
    _pageControl.top = _myCollection.bottom - 5;
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

- (void)_initToolbar{
    UIView *toolbar = [UIView new];
    toolbar.size = CGSizeMake(kScreenWidth, kToolbarHeight);
    
    UIImageView *bg = [[UIImageView alloc]initWithImage:[EmoticonHelper imageNamed:@"compose_emotion_table_right_normal"]];
    bg.size = toolbar.size;
    [toolbar addSubview:bg];
    
    UIScrollView *scroll = [UIScrollView new];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.alwaysBounceHorizontal = YES;
    scroll.size = toolbar.size;
    scroll.contentSize = toolbar.size;
    [toolbar addSubview:scroll];
    
    NSMutableArray *buttonS = [NSMutableArray new];
    for (int i = 0; i < _emoticonGroups.count; i++) {
        EmoticonGroup *group = _emoticonGroups[i];
        UIButton *btn = [self _createToolbarButton];
        [btn setTitle:group.nameCN forState:UIControlStateNormal];
        btn.left = kScreenWidth / (float)_emoticonGroups.count *i;
        btn.tag = i;
        btn.selected = !i;
        [scroll addSubview:btn];
        [buttonS addObject:btn];
    }
    
    toolbar.bottom = self.height;
    [self addSubview:toolbar];
    _toolbarButtons = buttonS;
}

- (UIButton *)_createToolbarButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.exclusiveTouch = YES;
    btn.size = CGSizeMake(kScreenWidth / _emoticonGroups.count, kToolbarHeight);
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:UIColorHex(5D5C5A) forState:UIControlStateSelected];
    
    UIImage *img;
    img = [EmoticonHelper imageNamed:@"compose_emotion_table_left_normal"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    img = [EmoticonHelper imageNamed:@"compose_emotion_table_left_selected"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(_toolbarBtnDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - Event Response
- (void)_toolbarBtnDidTapped:(UIButton *)sender{
    NSInteger groupIndex = sender.tag;
    NSInteger page = [_emoticonGroupPageIndexs[groupIndex] integerValue];
    CGRect rect = CGRectMake(page *_myCollection.width, 0, _myCollection.width, _myCollection.height);
    [_myCollection scrollRectToVisible:rect animated:NO];
    [self scrollViewDidScroll:_myCollection];
}

#pragma mark - EmotionScrollViewDelegate
- (void)emoticonScrollViewDidTapCell:(NormalEmotionCell *)cell{
    if (!cell) {
        return;
    }
    if (cell.isDelete) {
        if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapBackspace)]) {
            [[UIDevice currentDevice] playInputClick];
            [self.delegate emoticonInputDidTapBackspace];
        }
    }else if (cell.emoticon){
        NSString *text = nil;
        switch (cell.emoticon.type) {
            case EmoticonTypeEmoji:{
                NSNumber *num = [NSNumber numberWithString:cell.emoticon.code];
                text = [NSString stringWithUTF32Char:num.unsignedIntValue];
            } break;
            case EmoticonTypeImage:{
                text = cell.emoticon.chs;
            }break;
        }
        if (text && [self.delegate respondsToSelector:@selector(emoticonInputDidTapText:)]) {
            [self.delegate emoticonInputDidTapText:text];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _emoticonGroupTotalPageCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kOnePageCount + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NormalEmotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NormalEmotionCell" forIndexPath:indexPath];
    if (indexPath.row == kOnePageCount) {
        cell.isDelete = YES;
        cell.emoticon = nil;
    }else{
        cell.isDelete = NO;
        cell.emoticon = [self _emoticonForIndexPath:indexPath];
    }
    return cell;
}

- (Emoticon *)_emoticonForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    /*
     section 0~5    _emoticonGroups[0]
     section 6~9    _emoticonGroups[1]
     section 10~11  _emoticonGroups[2]
     */

    //判断当前section所在的索引
    Emoticon *model = nil;
    NSInteger currentIndex = 0;
    EmoticonGroup *group;
    NSInteger step2 = [_emoticonGroupPageIndexs[1] unsignedIntegerValue];
    NSInteger step3 = [_emoticonGroupPageIndexs[2] unsignedIntegerValue];
    if (section < step2) {
        group = _emoticonGroups[0];
        currentIndex = section *kOnePageCount + indexPath.row;
 
    }else if (section < step3 && section >= step2){
        group = _emoticonGroups[1];
        currentIndex = (section - step2) *kOnePageCount + indexPath.row;
        
    }else if (section >= step3){
        group = _emoticonGroups[2];
        currentIndex = (section - step3) *kOnePageCount + indexPath.row;
    }
    
    //坐标转换
    NSUInteger ip = currentIndex / kOnePageCount;
    NSUInteger ii = currentIndex % kOnePageCount;
    NSUInteger reIndex = (ii % 3) * 7 + (ii / 3);
    currentIndex = reIndex + ip * kOnePageCount;
    if (group.emoticons.count > currentIndex) {
        model = group.emoticons[currentIndex];
    }
    return model;
}

#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    /// 获取当前的页码
    NSInteger page = round(scrollView.contentOffset.x / scrollView.width);
    page = MIN(_emoticonGroupTotalPageCount - 1, MAX(0, page));
    if (page == _currentPageIndex) {
        return;
    }
    _currentPageIndex = page;
    NSInteger curGroupIndex = 0, curGroupPageIndex = 0, curGroupPageCount = 0;
    for (int i = 0; i < _emoticonGroupPageIndexs.count; i++) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (page >= pageIndex.unsignedIntegerValue) {
            curGroupIndex = i;
            curGroupPageIndex = [_emoticonGroupPageIndexs[i] integerValue];
            curGroupPageCount = [_emoticonGroupPageCounts[i] integerValue];
        }
    }
    
    /// 添加分页符
    [_pageControl.layer removeAllSublayers];
    CGFloat padding = 5, width = 6, height = 2;
    CGFloat pageControlWidth = (width + 2* padding) * curGroupPageCount;
    for (int i = 0; i < curGroupPageCount; i++) {
        CALayer *layer = [CALayer layer];
        layer.size = CGSizeMake(width, height);
        layer.cornerRadius = 1.0;
        if (page - curGroupPageIndex == i) {
            layer.backgroundColor = UIColorHex(fd8225).CGColor;
        }else{
            layer.backgroundColor = UIColorHex(dedede).CGColor;
        }
        layer.centerY = _pageControl.height / 2.0;
        layer.left = (_pageControl.width - pageControlWidth) / 2.0 + i * (width + 2 * padding) + padding;
        [_pageControl.layer addSublayer:layer];
    }
    
    /// 底部按钮数组滑动到指定位置
    [_toolbarButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = obj;
        btn.selected = (idx == curGroupIndex);
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end

