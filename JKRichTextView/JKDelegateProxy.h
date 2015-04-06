//
//  JKDelegateProxy.h
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-3.
//
//

#import <Foundation/Foundation.h>

@interface JKDelegateProxy : NSObject

- (instancetype)initWithDelegateProxy:(id)proxy;

/**
 Proxy will not perform selector if delegate target able to responds to selector only if this property is NO.
 
 @discussion Default is YES. It means whatever target have implement delegate methods delegate proxy will always forward it's invocation.
 */
@property (nonatomic) BOOL proxyForwardInvocationWhenTargetRespondsToSelector;

@property (nonatomic, weak, readonly) id delegateProxy;

- (NSArray *)allDelegateTargets;

- (void)addDelegateTarget:(id)delegateTarget;

- (void)removeDelegateTarget:(id)delegateTarget;

@end
