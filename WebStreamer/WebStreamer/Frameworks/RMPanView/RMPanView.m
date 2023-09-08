//
//  RMPanView.m
//  RandomMusicPlayer
//
//  Created by APPLE'S iMac on 6/15/20.
//  Copyright © 2020 Fredc Weber. All rights reserved.
//

#import "RMPanView.h"
#import "WebStreamer-Swift.h"

@interface RMPanView () <UIGestureRecognizerDelegate>
{
    
}

@property (nonatomic, strong) UIView *contentsView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation RMPanView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        [self commonInit];
        
        self.contentsView = view;
        [self addSubview:view];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.visible = NO;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.minHeight = 300;
    } else {
        self.minHeight = 480;
    }
    self.maxHeight = 504;
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentsView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showInView:(UIView *)view offset:(CGFloat)offset {
    [view addSubview:self];
    self.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 0);
    self.contentsView.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - 20);
    self.visible = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.maxHeight - offset, self.frame.size.width, self.maxHeight);
        self.contentsView.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - 20);
    }];
}

- (void)hide {
    UIView *superView = self.superview;
    if (superView == nil) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewWillHide:)]) {
        [self.delegate viewWillHide:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = superView.frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        self.visible = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewDidHide:)]) {
            [self.delegate viewDidHide:self];
        }
    }];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    if (self.frame.size.height - translation.y < self.minHeight) {
        translation.y = self.frame.size.height - self.minHeight;
    }
    if (self.frame.size.height - translation.y > self.maxHeight) {
        translation.y = self.frame.size.height - self.maxHeight;
    }
    
    CGRect frame = self.frame;
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        frame.origin.y += translation.y;
        frame.size.height -= translation.y;
        self.frame = frame;
        self.contentsView.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - 20);
    } else {
        CGFloat middle = (self.maxHeight - self.minHeight) / 2.0;
        if (frame.size.height - translation.y >= self.maxHeight - middle) {
            translation.y = self.frame.size.height - self.maxHeight;
        } else {
            translation.y = self.frame.size.height - self.minHeight;
        }
        frame.origin.y += translation.y;
        frame.size.height -= translation.y;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
            self.contentsView.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - 20);
        }];
    }
    
    [gesture setTranslation:CGPointZero inView:self];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    
    UIView *view = touch.view;
    while (view != nil) {
        if ([view isKindOfClass:[UITableView class]]) {
            return NO;
        }
        
        view = view.superview;
    }
    
    return YES;
}

@end
