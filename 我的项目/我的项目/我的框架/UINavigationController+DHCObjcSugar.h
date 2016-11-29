//
//  UINavigationController+DHCObjcSugar.h
//  DHCObjcSugar
//
//  Created by 姜超 on 16/3/26.
//  Copyright © 2016年 jiangchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (DHCObjcSugar)

/// 自定义全屏拖拽返回手势
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *dhc_popGestureRecognizer;

@end
