//
//  UINavigationController+DHCObjcSugar.m
//  DHCObjcSugar
//
//  Created by 姜超 on 16/3/26.
//  Copyright © 2016年 jiagnchao. All rights reserved.
//

#import "UINavigationController+DHCObjcSugar.h"
#import <objc/runtime.h>

@interface DHCFullScreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation DHCFullScreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

@implementation UINavigationController (DHCObjcSugar)

+ (void)load {
    
    Method originalMethod = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(dhc_pushViewController:animated:));
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)dhc_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.dhc_popGestureRecognizer]) {
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.dhc_popGestureRecognizer];
        
        NSArray *targets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [targets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        
        self.dhc_popGestureRecognizer.delegate = [self dhc_fullScreenPopGestureRecognizerDelegate];
        [self.dhc_popGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // 禁用系统的交互手势
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (![self.viewControllers containsObject:viewController]) {
        [self dhc_pushViewController:viewController animated:animated];
    }
}

- (DHCFullScreenPopGestureRecognizerDelegate *)dhc_fullScreenPopGestureRecognizerDelegate {
    DHCFullScreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    if (!delegate) {
        delegate = [[DHCFullScreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)dhc_popGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    
    if (panGestureRecognizer == nil) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

@end
