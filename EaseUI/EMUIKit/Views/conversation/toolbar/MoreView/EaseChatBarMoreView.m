/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseChatBarMoreView.h"

#import "SBEaseHelper.h"

#define CHAT_BUTTON_SIZE CGSizeMake(50,60)
#define INSETS 10
#define MOREVIEW_COL 4
#define MOREVIEW_ROW 2
#define MOREVIEW_BUTTON_TAG 1000

@implementation UIView (MoreView)

- (void)removeAllSubview
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end

@interface EaseChatBarMoreView ()<UIScrollViewDelegate>
{
    NSInteger _maxIndex;
}

@property (nonatomic) EMChatToolbarType type;

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *audioCallButton;
@property (nonatomic, strong) UIButton *videoCallButton;

@end

@implementation EaseChatBarMoreView

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseChatBarMoreView *moreView = [self appearance];
    moreView.moreViewBackgroundColor = [UIColor whiteColor];
}

- (instancetype)initWithFrame:(CGRect)frame type:(EMChatToolbarType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        [self setupSubviewsForType:_type];
    }
    return self;
}

- (void)setupSubviewsForType:(EMChatToolbarType)type
{
    //self.backgroundColor = [UIColor clearColor];
    self.accessibilityIdentifier = @"more_view";
    
    _scrollview = [[UIScrollView alloc] init];
    _scrollview.pagingEnabled = YES;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.delegate = self;
    [self addSubview:_scrollview];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = 1;
    [self addSubview:_pageControl];
    
    CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE.width) / 5;
    
    _photoButton = [self btnWithImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_photo"]
                     highlightedImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_photoSelected"]
                                title:@"相册"];

    _photoButton.accessibilityIdentifier = @"image";
    [_photoButton setFrame:CGRectMake(insets, 10, CHAT_BUTTON_SIZE.width , CHAT_BUTTON_SIZE.height)];
    [_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    _photoButton.tag = MOREVIEW_BUTTON_TAG;
    [_scrollview addSubview:_photoButton];
    
    _locationButton = [self btnWithImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_location"]
                        highlightedImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_locationSelected"]
                                   title:@"位置"];
    _locationButton.accessibilityIdentifier = @"location";
    [_locationButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE.width, 10, CHAT_BUTTON_SIZE.width , CHAT_BUTTON_SIZE.height)];
    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    _locationButton.tag = MOREVIEW_BUTTON_TAG + 1;
    [_scrollview addSubview:_locationButton];
    
    _takePicButton = [self btnWithImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_camera"]
                       highlightedImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_cameraSelected"]
                                  title:@"拍照"];
    [_takePicButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE.width * 2, 10, CHAT_BUTTON_SIZE.width , CHAT_BUTTON_SIZE.height)];
    [_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
    _takePicButton.tag = MOREVIEW_BUTTON_TAG + 2;
    _maxIndex = 2;
    [_scrollview addSubview:_takePicButton];
    
    _audioCallButton = [self btnWithImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_audioCall"]
                         highlightedImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_audioCallSelected"]
                                    title:nil];
    [_audioCallButton setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE.width * 3, 10, CHAT_BUTTON_SIZE.width , CHAT_BUTTON_SIZE.height)];
    [_audioCallButton addTarget:self action:@selector(takeAudioCallAction) forControlEvents:UIControlEventTouchUpInside];
    _audioCallButton.tag = MOREVIEW_BUTTON_TAG + 3;
    [_scrollview addSubview:_audioCallButton];
    
    _videoCallButton = [self btnWithImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_videoCall"]
                         highlightedImage:[SBEaseHelper imageWithName:@"EaseUIResource.bundle/chatBar_colorMore_videoCallSelected"]
                                    title:nil];
    [_videoCallButton setFrame:CGRectMake(insets, 10 * 2 + CHAT_BUTTON_SIZE.height + 10, CHAT_BUTTON_SIZE.width , CHAT_BUTTON_SIZE.height)];
    [_videoCallButton addTarget:self action:@selector(takeVideoCallAction) forControlEvents:UIControlEventTouchUpInside];
    _videoCallButton.tag =MOREVIEW_BUTTON_TAG + 4;
    _maxIndex = 4;
    [_scrollview addSubview:_videoCallButton];

    CGRect frame = self.frame;
    frame.size.height = 150;
    if (type == EMChatToolbarTypeChat) {
        [_audioCallButton setTitle:@"语音" forState:UIControlStateNormal];
        [_videoCallButton setTitle:@"视频" forState:UIControlStateNormal];
    }
    else if (type == EMChatToolbarTypeGroup)
    {
        [_audioCallButton setTitle:@"多人会议" forState:UIControlStateNormal];
        [_videoCallButton setTitle:@"互动会议" forState:UIControlStateNormal];
    }
    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}


- (UIButton *)btnWithImage:(UIImage *)aImage highlightedImage:(UIImage *)aHighLightedImage title:(NSString *)aTitle {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:aImage forState:UIControlStateNormal];
    [btn setImage:aHighLightedImage forState:UIControlStateHighlighted];
    [btn setTitle:aTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    btn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 20, 0);
    btn.titleEdgeInsets = UIEdgeInsetsMake(14, -60, -20, 0);
    return btn;
}

- (void)insertItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE.width) / 5;
    CGRect frame = self.frame;
    _maxIndex++;
    NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
    NSInteger page = _maxIndex/pageSize;
    NSInteger row = (_maxIndex%pageSize)/MOREVIEW_COL;
    NSInteger col = _maxIndex%MOREVIEW_COL;
    UIButton *moreButton = [self btnWithImage:image highlightedImage:highLightedImage title:title];
    [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE.width * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE.height * row, CHAT_BUTTON_SIZE.width , CHAT_BUTTON_SIZE.height)];
    [moreButton setImage:image forState:UIControlStateNormal];
    [moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.tag = MOREVIEW_BUTTON_TAG+_maxIndex;
    [_scrollview addSubview:moreButton];
    [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
    [_pageControl setNumberOfPages:page + 1];
    if (_maxIndex >=5) {
        frame.size.height = 150;
        _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    }
    self.frame = frame;
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

- (void)updateItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title atIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [(UIButton*)moreButton setImage:image forState:UIControlStateNormal];
        [(UIButton*)moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    }
}

- (void)removeItematIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [self _resetItemFromIndex:index];
        [moreButton removeFromSuperview];
    }
}

#pragma mark - private

- (void)_resetItemFromIndex:(NSInteger)index
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE.width) / 5;
    CGRect frame = self.frame;
    for (NSInteger i = index + 1; i<_maxIndex + 1; i++) {
        UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+i];
        if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
            NSInteger moveToIndex = i - 1;
            NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
            NSInteger page = moveToIndex/pageSize;
            NSInteger row = (moveToIndex%pageSize)/MOREVIEW_COL;
            NSInteger col = moveToIndex%MOREVIEW_COL;
            [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE.width * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE.height * row, CHAT_BUTTON_SIZE.width , CHAT_BUTTON_SIZE.height)];
            moreButton.tag = MOREVIEW_BUTTON_TAG+moveToIndex;
            [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
            [_pageControl setNumberOfPages:page + 1];
        }
    }
    _maxIndex--;
    if (_maxIndex >=5) {
        frame.size.height = 150;
    } else {
        frame.size.height = 80;
    }
    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

#pragma setter
//- (void)setMoreViewColumn:(NSInteger)moreViewColumn
//{
//    if (_moreViewColumn != moreViewColumn) {
//        _moreViewColumn = moreViewColumn;
//        [self setupSubviewsForType:_type];
//    }
//}
//
//- (void)setMoreViewNumber:(NSInteger)moreViewNumber
//{
//    if (_moreViewNumber != moreViewNumber) {
//        _moreViewNumber = moreViewNumber;
//        [self setupSubviewsForType:_type];
//    }
//}

- (void)setMoreViewBackgroundColor:(UIColor *)moreViewBackgroundColor
{
    _moreViewBackgroundColor = moreViewBackgroundColor;
    if (_moreViewBackgroundColor) {
        [self setBackgroundColor:_moreViewBackgroundColor];
    }
}

/*
- (void)setMoreViewButtonImages:(NSArray *)moreViewButtonImages
{
    _moreViewButtonImages = moreViewButtonImages;
    if ([_moreViewButtonImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonImages count]) {
                    NSString *imageName = [_moreViewButtonImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)setMoreViewButtonHignlightImages:(NSArray *)moreViewButtonHignlightImages
{
    _moreViewButtonHignlightImages = moreViewButtonHignlightImages;
    if ([_moreViewButtonHignlightImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonHignlightImages count]) {
                    NSString *imageName = [_moreViewButtonHignlightImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
                }
            }
        }
    }
}*/

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset =  scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

#pragma mark - action

- (void)takePicAction{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)photoAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}

- (void)locationAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}

- (void)takeAudioCallAction
{
    if (_delegate) {
        if (self.type == EMChatToolbarTypeChat) {
            if ([_delegate respondsToSelector:@selector(moreViewAudioCallAction:)]) {
                [_delegate moreViewAudioCallAction:self];
            }
        } else if (self.type == EMChatToolbarTypeGroup) {
            if ([_delegate respondsToSelector:@selector(moreViewCommunicationAction:)]) {
                [_delegate moreViewCommunicationAction:self];
            }
        }
    }
}

- (void)takeVideoCallAction
{
    if (_delegate) {
        if (self.type == EMChatToolbarTypeChat) {
            if ([_delegate respondsToSelector:@selector(moreViewVideoCallAction:)]) {
                [_delegate moreViewVideoCallAction:self];
            }
        } else if (self.type == EMChatToolbarTypeGroup) {
            if ([_delegate respondsToSelector:@selector(moreViewLiveAction:)]) {
                [_delegate moreViewLiveAction:self];
            }
        }
    }
}

- (void)moreAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button && _delegate && [_delegate respondsToSelector:@selector(moreView:didItemInMoreViewAtIndex:)]) {
        [_delegate moreView:self didItemInMoreViewAtIndex:button.tag-MOREVIEW_BUTTON_TAG];
    }
}

@end
