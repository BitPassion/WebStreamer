
//
//  YJLActionMenuItem.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/14/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#define noDisableVerticalScrollTag 836913
//#define noDisableHorizontalScrollTag 836914


@interface YJLActionMenuItem: NSObject

@property (readwrite, nonatomic, strong) UIImage *image;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, weak) id target;
@property (readwrite, nonatomic) SEL action;
@property (readwrite, nonatomic) int index;
@property (readwrite, nonatomic) CGFloat value;
@property (readwrite, nonatomic, strong) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype)menuItem:(NSString *)title
                   image:(UIImage *)image
                  target:(id)target
                  action:(SEL)action;

+ (instancetype)menuItem:(NSString *)title
                   image:(UIImage *)image
                  target:(id)target
                  action:(SEL)action
                   index:(int)index;

+ (instancetype)menuItem:(NSString *)title
                   image:(UIImage *)image
                  target:(id)target
                  action:(SEL)action
                   value:(CGFloat)value;

@end

@interface YJLActionMenu : NSObject

+ (void)showMenuInView:(UIView *)view
              fromRect:(CGRect)rect
             menuItems:(NSArray *)menuItems isWhiteBG:(BOOL)backgroundType;

+ (void)dismissMenu;

+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;

+ (UIFont *)titleFont;
+ (void)setTitleFont:(UIFont *)titleFont;

@end
