//
//  JKDelegateProxy.m
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-3.
//
//

#import "JKDelegateProxy.h"

@interface JKDelegateProxy ()
@property (nonatomic, weak) id delegateProxy;
@property (nonatomic, strong) NSHashTable *delegateTargets;
@end

@implementation JKDelegateProxy

- (instancetype)initWithDelegateProxy:(id)proxy {
    self = [super init];
    if (self) {
        self.delegateProxy = proxy;
        self.proxyForwardInvocationWhenTargetRespondsToSelector = YES;
    }
    return self;
}

- (NSHashTable *)delegateTargets {
    if(!_delegateTargets) {
        _delegateTargets = [NSHashTable weakObjectsHashTable];
    }
    return _delegateTargets;
}

- (NSArray *)allDelegateTargets {
    return [self.delegateTargets allObjects];
}

- (void)addDelegateTarget:(id)delegateTarget {
    NSAssert(delegateTarget != self.delegateProxy, @"Cannot set delegate proxy as one of delegate targets");
    NSHashTable *delegateTargets = self.delegateTargets.copy;
    [delegateTargets addObject:delegateTarget];
    self.delegateTargets = delegateTargets;
}

- (void)removeDelegateTarget:(id)delegateTarget {
    NSHashTable *delegateTargets = self.delegateTargets.copy;
    [delegateTargets removeObject:delegateTarget];
    self.delegateTargets = delegateTargets;
}

#pragma mark -
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    for (id delegateTarget in self.delegateTargets) {
        if([delegateTarget respondsToSelector:aSelector]) return [delegateTarget methodSignatureForSelector:aSelector];
    }
    
    if([self.delegateProxy respondsToSelector:aSelector]) return [self.delegateProxy methodSignatureForSelector:aSelector];
    
    return nil;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    for (id delegateTarget in self.delegateTargets) {
        if([delegateTarget respondsToSelector:aSelector]) return YES;
    }
    
    return [self.delegateProxy respondsToSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    
    BOOL delegateTargetForwardedInvocation = NO;
    
    for (id delegateTarget in self.delegateTargets) {
        if([delegateTarget respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegateTarget];
            delegateTargetForwardedInvocation = YES;
        }
    }
    
    if(!delegateTargetForwardedInvocation || (delegateTargetForwardedInvocation && self.proxyForwardInvocationWhenTargetRespondsToSelector)) {
        if([self.delegateProxy respondsToSelector:invocation.selector]) [invocation invokeWithTarget:self.delegateProxy];
    }
}

@end
