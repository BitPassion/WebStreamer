//
//  YJLActionMenuItem.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/14/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLActionMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+Extension.h"

const CGFloat kArrowSize = 12.f;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@interface YJLActionMenuView : UIView <UIGestureRecognizerDelegate>

- (void)dismissMenu:(BOOL)animated;

@end

@interface YJLActionMenuOverlay : UIView
@end

@implementation YJLActionMenuOverlay


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        UITapGestureRecognizer *gestureRecognizer;
        gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(singleTap:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

// thank horaceho https://github.com/horaceho
// for his solution described in https://github.com/kolyvan/YJLActionMenu/issues/9

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[YJLActionMenuView class]] && [v respondsToSelector:@selector(dismissMenu:)]) {
            [v performSelector:@selector(dismissMenu:) withObject:@(YES)];
        }
    }
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

@implementation YJLActionMenuItem

+ (instancetype)menuItem:(NSString *)title
                   image:(UIImage *)image
                  target:(id)target
                  action:(SEL)action
{
    return [[YJLActionMenuItem alloc] init:title
                                     image:image
                                    target:target
                                    action:action];
}

+ (instancetype)menuItem:(NSString *)title
                   image:(UIImage *)image
                  target:(id)target
                  action:(SEL)action
                   index:(int)index
{
    return [[YJLActionMenuItem alloc] init:title
                                     image:image
                                    target:target
                                    action:action
                                     index:index];
}

+ (instancetype)menuItem:(NSString *)title
                   image:(UIImage *)image
                  target:(id)target
                  action:(SEL)action
                   value:(CGFloat)value
{
    return [[YJLActionMenuItem alloc] init:title
                                     image:image
                                    target:target
                                    action:action
                                     value:value];
}

- (id)init:(NSString *)title
     image:(UIImage *)image
    target:(id)target
    action:(SEL)action
{
    NSParameterAssert(title.length || image);
    
    self = [super init];
    if (self) {
        _title = title;
        _image = image;
        _target = target;
        _action = action;
    }
    return self;
}

- (id)init:(NSString *)title
     image:(UIImage *)image
    target:(id)target
    action:(SEL)action
     index:(int)index
{
    NSParameterAssert(title.length || image);
    
    self = [super init];

    if (self)
    {
        _title = title;
        _image = image;
        _target = target;
        _action = action;
        _index = index;
    }
    
    return self;
}

- (id)init:(NSString *)title
     image:(UIImage *)image
    target:(id)target
    action:(SEL)action
     value:(CGFloat)value
{
    NSParameterAssert(title.length || image);
    
    self = [super init];
    
    if (self)
    {
        _title = title;
        _image = image;
        _target = target;
        _action = action;
        _value = value;
    }
    
    return self;
}

- (BOOL) enabled
{
    return _target != nil && _action != NULL;
}

- (void) performAction
{
    __strong id target = self.target;
    
    if (target && [target respondsToSelector:_action]) {
        
        [target performSelectorOnMainThread:_action withObject:self waitUntilDone:YES];
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@ #%p %@>", [self class], self, _title];
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef enum {
  
    YJLActionMenuViewArrowDirectionNone,
    YJLActionMenuViewArrowDirectionUp,
    YJLActionMenuViewArrowDirectionDown,
    YJLActionMenuViewArrowDirectionLeft,
    YJLActionMenuViewArrowDirectionRight,
    
} YJLActionMenuViewArrowDirection;



@implementation YJLActionMenuView {
    
    YJLActionMenuViewArrowDirection    _arrowDirection;
    CGFloat                     _arrowPosition;
    UIScrollView                      *_contentView;
    NSArray                     *_menuItems;
    BOOL isWhiteBG;
}

- (id)init
{
    self = [super initWithFrame:CGRectZero];    
    if(self) {

        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.alpha = 0;
        
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        self.layer.shadowRadius = 2;
    }
    
    return self;
}


- (void) setupFrameInView:(UIView *)view
                 fromRect:(CGRect)fromRect
{
    const CGSize contentSize = _contentView.frame.size;
    
    const CGFloat outerWidth = view.bounds.size.width;
    const CGFloat outerHeight = view.bounds.size.height;
    
    const CGFloat rectX0 = fromRect.origin.x;
    const CGFloat rectX1 = fromRect.origin.x + fromRect.size.width;
    const CGFloat rectXM = fromRect.origin.x + fromRect.size.width * 0.5f;
    const CGFloat rectY0 = fromRect.origin.y;
    const CGFloat rectY1 = fromRect.origin.y + fromRect.size.height;
    const CGFloat rectYM = fromRect.origin.y + fromRect.size.height * 0.5f;;
    
    const CGFloat widthPlusArrow = contentSize.width + kArrowSize;
    const CGFloat heightPlusArrow = contentSize.height + kArrowSize;
    const CGFloat widthHalf = contentSize.width * 0.5f;
    const CGFloat heightHalf = contentSize.height * 0.5f;
    
    const CGFloat kMargin = 5.0f;
    
    if (heightPlusArrow < (outerHeight - rectY1)) {
    
        _arrowDirection = YJLActionMenuViewArrowDirectionUp;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY1
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){0, kArrowSize, contentSize};
                
        self.frame = (CGRect) {
            point,
            contentSize.width,
            contentSize.height + kArrowSize
        };
        
        if (self.frame.origin.x + self.frame.size.width > view.frame.size.width - view.safeAreaInsets.right) {
            CGRect frame = self.frame;
            frame.origin = CGPointMake(self.frame.origin.x - view.safeAreaInsets.right, self.frame.origin.y);
            self.frame = frame;
            _arrowPosition += view.safeAreaInsets.right;
        } else if (self.frame.origin.x < view.safeAreaInsets.left) {
            CGRect frame = self.frame;
            frame.origin = CGPointMake(view.safeAreaInsets.left, self.frame.origin.y);
            self.frame = frame;
            _arrowPosition -= view.safeAreaInsets.left;
        }
        
    } else if (heightPlusArrow < rectY0) {
        _arrowDirection = YJLActionMenuViewArrowDirectionDown;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY0 - heightPlusArrow
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            point,
            contentSize.width,
            contentSize.height + kArrowSize
        };
        
        if (self.frame.origin.x + self.frame.size.width > view.frame.size.width - view.safeAreaInsets.right) {
            CGRect frame = self.frame;
            frame.origin = CGPointMake(self.frame.origin.x - view.safeAreaInsets.right, self.frame.origin.y);
            self.frame = frame;
            _arrowPosition += view.safeAreaInsets.right;
        } else if (self.frame.origin.x < view.safeAreaInsets.left) {
            CGRect frame = self.frame;
            frame.origin = CGPointMake(view.safeAreaInsets.left, self.frame.origin.y);
            self.frame = frame;
            _arrowPosition -= view.safeAreaInsets.left;
        }
        
    } else if (widthPlusArrow < (outerWidth - rectX1)) {
        
        _arrowDirection = YJLActionMenuViewArrowDirectionLeft;
        CGPoint point = (CGPoint){
            rectX1,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + kMargin) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){kArrowSize, 0, contentSize};
        
        self.frame = (CGRect) {
            point,
            contentSize.width + kArrowSize,
            contentSize.height
        };
        
        if (self.frame.origin.x + self.frame.size.width > view.frame.size.width - view.safeAreaInsets.right) {
            CGRect frame = self.frame;
            frame.origin = CGPointMake(self.frame.origin.x - view.safeAreaInsets.right, self.frame.origin.y);
            self.frame = frame;
        }
        
    } else if (widthPlusArrow < rectX0) {
        
        _arrowDirection = YJLActionMenuViewArrowDirectionRight;
        CGPoint point = (CGPoint){
            rectX0 - widthPlusArrow,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + 5) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            point,
            contentSize.width  + kArrowSize,
            contentSize.height
        };
        
    } else {
        
        _arrowDirection = YJLActionMenuViewArrowDirectionLeft;

        CGPoint point = (CGPoint){
            outerWidth - widthPlusArrow,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + kMargin) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){kArrowSize, 0, contentSize};
        
        self.frame = (CGRect) {
            point,
            contentSize.width + kArrowSize,
            contentSize.height
        };
    }
}

- (void)showMenuInView:(UIView *)view
              fromRect:(CGRect)rect
             menuItems:(NSArray *)menuItems isWhiteBG:(BOOL)type
{
    _menuItems = menuItems;
    isWhiteBG = type;
    
    _contentView = [self makeContentView];
    [self addSubview:_contentView];
    
    [_contentView flashScrollIndicators];
    
    [self setupFrameInView:view fromRect:rect];
    
    YJLActionMenuOverlay *overlay = [[YJLActionMenuOverlay alloc] initWithFrame:view.bounds];
    [overlay addSubview:self];
    [view addSubview:overlay];
    
    _contentView.hidden = YES;
    CGRect toFrame = self.frame;
    self.frame = (CGRect){self.arrowPoint, 1, 1};
    
    UIScrollView *__contentView = _contentView;
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                         
                     } completion:^(BOOL completed) {
                         __contentView.hidden = NO;
                     }];
   
}

- (void)dismissMenu:(BOOL)animated
{
    if (self.superview) {
     
        if (animated) {
            
            _contentView.hidden = YES;            
            const CGRect toFrame = (CGRect){self.arrowPoint, 1, 1};
            
            UIScrollView *__contentView = _contentView;
            [UIView animateWithDuration:0.2f
                             animations:^(void) {
                                 
                                 self.alpha = 0;
                                 self.frame = toFrame;
                                 __contentView.frame = toFrame;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 if ([self.superview isKindOfClass:[YJLActionMenuOverlay class]])
                                     [self.superview removeFromSuperview];
                                 [self removeFromSuperview];
                             }];
            
        } else {
            
            if ([self.superview isKindOfClass:[YJLActionMenuOverlay class]])
                [self.superview removeFromSuperview];
            [self removeFromSuperview];
        }
    }
}

- (void)performAction:(UITapGestureRecognizer *)sender
{
    [self dismissMenu:YES];
    
    UIImageView *button = (UIImageView *)sender.view;
    
    YJLActionMenuItem *menuItem = _menuItems[button.tag];


    [menuItem performAction];
}

- (UIScrollView *) makeContentView
{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    if (!_menuItems.count)
        return nil;
    
    const CGFloat kMinMenuItemHeight = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 32.0f : 40.0f;
    const CGFloat kMinMenuItemWidth = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 32.0f : 40.0f;

    const CGFloat kMarginX = 10.f;
    const CGFloat kMarginY = 5.f;
    
    UIFont *titleFont = [YJLActionMenu titleFont];
    
    if (!titleFont)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            titleFont = [UIFont fontWithName:@"MyriadPro-Semibold" size:[UIFont systemFontSize] + 4.0f];
        }
        else
        {
            titleFont = [UIFont fontWithName:@"MyriadPro-Semibold" size:[UIFont systemFontSize] + 2.0f];
        }
    }
    
    CGFloat maxImageWidth = 0;    
    CGFloat maxItemHeight = 0;
    CGFloat maxItemWidth = 0;
    
    for (YJLActionMenuItem *menuItem in _menuItems) {
        
        const CGSize imageSize = menuItem.image.size;        
        if (imageSize.width > maxImageWidth)
            maxImageWidth = imageSize.width;        
    }
    
    if (maxImageWidth) {
        maxImageWidth += kMarginX;
    }
    
    for (YJLActionMenuItem *menuItem in _menuItems) {

        const CGSize titleSize = [menuItem.title sizeWithAttributes: @{NSFontAttributeName:titleFont}];

        const CGSize imageSize = menuItem.image.size;

        const CGFloat itemHeight = MAX(titleSize.height, imageSize.height) + kMarginY * 2;
        const CGFloat itemWidth = ((!menuItem.enabled && !menuItem.image) ? titleSize.width : maxImageWidth + titleSize.width) + kMarginX * 4;
        
        if (itemHeight > maxItemHeight)
            maxItemHeight = itemHeight;
        
        if (itemWidth > maxItemWidth)
            maxItemWidth = itemWidth;
    }
       
    maxItemWidth  = MAX(maxItemWidth, kMinMenuItemWidth);
    maxItemHeight = MAX(maxItemHeight, kMinMenuItemHeight);

    const CGFloat titleX = kMarginX * 2 + maxImageWidth;
    const CGFloat titleWidth = maxItemWidth - titleX - kMarginX * 2;
    
    UIImage *gradientLine = [YJLActionMenuView gradientLine: (CGSize){maxItemWidth - kMarginX * 4, 1}];

    UIScrollView* contentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    contentView.autoresizingMask = UIViewAutoresizingNone;
    contentView.backgroundColor = [UIColor clearColor];
    contentView.opaque = NO;
    contentView.scrollEnabled = YES;
    //contentView.tag = noDisableVerticalScrollTag;
    contentView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    contentView.automaticallyAdjustsScrollIndicatorInsets = NO;
    contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    CGFloat itemY = kMarginY * 2;
    NSUInteger itemNum = 0;
        
    for (YJLActionMenuItem *menuItem in _menuItems) {
                
        const CGRect itemFrame = (CGRect){0, itemY, maxItemWidth, maxItemHeight};
        
        UIView *itemView = [[UIView alloc] initWithFrame:itemFrame];
        itemView.autoresizingMask = UIViewAutoresizingNone;
        itemView.backgroundColor = [UIColor clearColor];        
        itemView.opaque = NO;
        [contentView addSubview:itemView];
        
        if (menuItem.enabled) {
        
            UIImageView *button = [[UIImageView alloc] initWithFrame:itemView.bounds];
            button.tag = itemNum;
            button.backgroundColor = [UIColor clearColor];
            button.opaque = NO;
            button.autoresizingMask = UIViewAutoresizingNone;
            button.userInteractionEnabled = YES;
            [itemView addSubview:button];
            
            UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performAction:)];
            selectGesture.delegate = self;
            [button addGestureRecognizer:selectGesture];
            [selectGesture setNumberOfTapsRequired:1];

        }
        
        if (menuItem.title.length) {
            
            CGRect titleFrame;
            
            if (!menuItem.enabled && !menuItem.image) {
                
                titleFrame = (CGRect){
                    kMarginX * 2,
                    kMarginY,
                    maxItemWidth - kMarginX * 4,
                    maxItemHeight - kMarginY * 2
                };
                
            } else {
                
                titleFrame = (CGRect){
                    titleX,
                    kMarginY,
                    titleWidth,
                    maxItemHeight - kMarginY * 2
                };
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
            titleLabel.text = menuItem.title;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = menuItem.alignment;
            
            if (isWhiteBG)
            {
                titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : [UIColor grayColor];
            }
            else
            {
                titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : [UIColor whiteColor];
            }
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.autoresizingMask = UIViewAutoresizingNone;
            [itemView addSubview:titleLabel];
        }
        
        if (menuItem.image) {
            
            const CGRect imageFrame = {kMarginX * 2, kMarginY, maxImageWidth, maxItemHeight - kMarginY * 2};
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = menuItem.image;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingNone;
            [itemView addSubview:imageView];
        }
        
        if (itemNum < _menuItems.count - 1) {
            
            UIImageView *gradientView = [[UIImageView alloc] initWithImage:gradientLine];
            gradientView.frame = (CGRect){kMarginX * 2, maxItemHeight + 1, gradientLine.size};
            gradientView.contentMode = UIViewContentModeLeft;
            [itemView addSubview:gradientView];
            
            itemY += 2;
        }
        
        itemY += maxItemHeight;
        ++itemNum;
    }    
    
    CGFloat contentHeight = itemY + kMarginY * 2;
    CGFloat maxHeight = 0.0f;

    UIInterfaceOrientation orientation = [UIApplication orientation];
    CGRect bounds = [UIScreen mainScreen].bounds;
#if TARGET_OS_MACCATALYST
    bounds = SCREEN_FRAME_LANDSCAPE;
#endif
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        maxHeight = bounds.size.width > bounds.size.height ? bounds.size.height : bounds.size.width;
    }
    else
    {
        maxHeight = bounds.size.width > bounds.size.height ? bounds.size.width : bounds.size.height;
    }
    
    if (contentHeight > maxHeight)
    {
        contentView.frame = CGRectMake(0, 0, maxItemWidth, maxHeight - kMinMenuItemHeight * 2.0 / 3.0);
        contentView.contentSize = CGSizeMake(maxItemWidth, contentHeight);
    }
    else
    {
        contentView.frame = CGRectMake(0, 0, maxItemWidth, contentHeight);
        contentView.contentSize = CGSizeMake(maxItemWidth, contentHeight);
    }
    
    return contentView;
}

- (CGPoint) arrowPoint
{
    CGPoint point;
    
    if (_arrowDirection == YJLActionMenuViewArrowDirectionUp) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMinY(self.frame) };
        
    } else if (_arrowDirection == YJLActionMenuViewArrowDirectionDown) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMaxY(self.frame) };
        
    } else if (_arrowDirection == YJLActionMenuViewArrowDirectionLeft) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else if (_arrowDirection == YJLActionMenuViewArrowDirectionRight) {
        
        point = (CGPoint){ CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else {
        
        point = self.center;
    }
    
    return point;
}

+ (UIImage *) selectedImage: (CGSize) size
{
    const CGFloat locations[] = {0,1};
    
    const CGFloat components[] = {
        0.216, 0.471, 0.871, 1,
        0.059, 0.353, 0.839, 1,
    };
    
    return [self gradientImageWithSize:size locations:locations components:components count:2];
}

+ (UIImage *) gradientLine: (CGSize) size
{
    const CGFloat locations[5] = {0,0.2,0.5,0.8,1};
    
    const CGFloat R = 0.44f, G = 0.44f, B = 0.44f;
        
    const CGFloat components[20] = {
        R,G,B,0.1,
        R,G,B,0.4,
        R,G,B,0.7,
        R,G,B,0.4,
        R,G,B,0.1
    };
    
    return [self gradientImageWithSize:size locations:locations components:components count:5];
}

+ (UIImage *) gradientImageWithSize:(CGSize) size
                          locations:(const CGFloat []) locations
                         components:(const CGFloat []) components
                              count:(NSUInteger)count
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(context, colorGradient, (CGPoint){0, 0}, (CGPoint){size.width, 0}, 0);
    CGGradientRelease(colorGradient);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) drawRect:(CGRect)rect
{
    [self drawBackground:self.bounds
               inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawBackground:(CGRect)frame
             inContext:(CGContextRef) context
{
    CGFloat R0 = 1.0, G0 = 1.0, B0 = 1.0;
    CGFloat R1 = 1.0, G1 = 1.0, B1 = 1.0;

    if (isWhiteBG)
    {
        //white background
        R0 = 1.0; G0 = 1.0; B0 = 1.0;
        R1 = 1.0; G1 = 1.0; B1 = 1.0;
    }
    else
    {
        //gray background
        R0 = 0.267; G0 = 0.303; B0 = 0.335;
        R1 = 0.040; G1 = 0.040; B1 = 0.040;
    }

    UIColor *tintColor = [YJLActionMenu tintColor];
    if (tintColor) {
        
        CGFloat a;
        [tintColor getRed:&R0 green:&G0 blue:&B0 alpha:&a];
    }
    
    CGFloat X0 = frame.origin.x;
    CGFloat X1 = frame.origin.x + frame.size.width;
    CGFloat Y0 = frame.origin.y;
    CGFloat Y1 = frame.origin.y + frame.size.height;
    
    // render arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    // fix the issue with gap of arrow's base if on the edge
    const CGFloat kEmbedFix = 3.f;
    
    if (_arrowDirection == YJLActionMenuViewArrowDirectionUp) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - kArrowSize;
        const CGFloat arrowX1 = arrowXM + kArrowSize;
        const CGFloat arrowY0 = Y0;
        const CGFloat arrowY1 = Y0 + kArrowSize + kEmbedFix;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY0}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        Y0 += kArrowSize;
        
    } else if (_arrowDirection == YJLActionMenuViewArrowDirectionDown) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - kArrowSize;
        const CGFloat arrowX1 = arrowXM + kArrowSize;
        const CGFloat arrowY0 = Y1 - kArrowSize - kEmbedFix;
        const CGFloat arrowY1 = Y1;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY1}];
        
        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:1] set];
        
        Y1 -= kArrowSize;
        
    } else if (_arrowDirection == YJLActionMenuViewArrowDirectionLeft) {
        
        const CGFloat arrowYM = _arrowPosition;        
        const CGFloat arrowX0 = X0;
        const CGFloat arrowX1 = X0 + kArrowSize + kEmbedFix;
        const CGFloat arrowY0 = arrowYM - kArrowSize;;
        const CGFloat arrowY1 = arrowYM + kArrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:1] set];
        
        X0 += kArrowSize;
        
    } else if (_arrowDirection == YJLActionMenuViewArrowDirectionRight) {
        
        const CGFloat arrowYM = _arrowPosition;        
        const CGFloat arrowX0 = X1;
        const CGFloat arrowX1 = X1 - kArrowSize - kEmbedFix;
        const CGFloat arrowY0 = arrowYM - kArrowSize;;
        const CGFloat arrowY1 = arrowYM + kArrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:1] set];
        
        X1 -= kArrowSize;
    }
    
    [arrowPath fill];

    // render body
    
    const CGRect bodyFrame = {X0, Y0, X1 - X0, Y1 - Y0};
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:bodyFrame
                                                          cornerRadius:8];
        
    const CGFloat locations[] = {0, 1};
    const CGFloat components[] = {
        R0, G0, B0, 1,
        R1, G1, B1, 1,
    };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 components,
                                                                 locations,
                                                                 sizeof(locations)/sizeof(locations[0]));
    CGColorSpaceRelease(colorSpace);
    
    
    [borderPath addClip];
    
    CGPoint start, end;
    
    if (_arrowDirection == YJLActionMenuViewArrowDirectionLeft ||
        _arrowDirection == YJLActionMenuViewArrowDirectionRight) {
                
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X1, Y0};
        
    } else {
        
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X0, Y1};
    }
    
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    CGGradientRelease(gradient);    
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static YJLActionMenu *gMenu;
static UIColor *gTintColor;
static UIFont *gTitleFont;

@implementation YJLActionMenu {
    
    YJLActionMenuView *_menuView;
    BOOL        _observing;
    BOOL isWhiteBG;
}

+ (instancetype) sharedMenu
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        gMenu = [[YJLActionMenu alloc] init];
    });
    return gMenu;
}

- (id) init
{
    NSAssert(!gMenu, @"singleton object");
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
    if (_observing) {        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems isWhiteBG:(BOOL) backgroundType
{
    NSParameterAssert(view);
    NSParameterAssert(menuItems.count);
    
    isWhiteBG = backgroundType;
    
    if (_menuView) {
        
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }

    if (!_observing) {
    
        _observing = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationWillChange:)
                                                     name:UIDeviceOrientationDidChangeNotification//UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }

    _menuView = [[YJLActionMenuView alloc] init];
    [_menuView showMenuInView:view fromRect:rect menuItems:menuItems isWhiteBG:isWhiteBG];
}

- (void) dismissActionMenu
{
    if (_menuView) {
        
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }
    
    if (_observing) {
        
        _observing = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) orientationWillChange: (NSNotification *) n
{
    [self dismissActionMenu];
}

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems isWhiteBG:(BOOL) backgroundType;
{
    [[self sharedMenu] showMenuInView:view fromRect:rect menuItems:menuItems isWhiteBG:backgroundType];
}

+ (void) dismissMenu
{
    [[self sharedMenu] dismissActionMenu];
}

+ (UIColor *) tintColor
{
    return gTintColor;
}

+ (void) setTintColor: (UIColor *) tintColor
{
    if (tintColor != gTintColor) {
        gTintColor = tintColor;
    }
}

+ (UIFont *) titleFont
{
    return gTitleFont;
}

+ (void) setTitleFont: (UIFont *) titleFont
{
    if (titleFont != gTitleFont) {
        gTitleFont = titleFont;
    }
}

@end

