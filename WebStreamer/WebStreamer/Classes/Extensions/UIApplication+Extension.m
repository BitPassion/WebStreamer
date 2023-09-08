//
//  UIApplication+Extension.m
//  VideoDreamer
//
//  Created by Yinjing Li on 2/15/23.
//

#import "UIApplication+Extension.h"

@implementation UIApplication (Extension)

+ (UIInterfaceOrientation)orientation {
    //if (@available(iOS 13.0, *)) {
        return [UIApplication sharedApplication].windows.firstObject.windowScene.interfaceOrientation;
    //} else {
    //    return [UIApplication sharedApplication].statusBarOrientation;
    //}
}

+ (UIWindow *)keyWindow {
   NSPredicate *isKeyWindow = [NSPredicate predicateWithFormat:@"isKeyWindow == YES"];
   return [[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate:isKeyWindow].firstObject;
}

@end
