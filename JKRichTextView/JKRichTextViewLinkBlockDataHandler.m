//
//  JKRichTextViewLinkBlockDataHandler.m
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-7.
//
//

#import "JKRichTextViewLinkBlockDataHandler.h"
#import <objc/runtime.h>

static NSString * const JKRichTextViewLinkBlockDataHandlerLinkPlaceholder = @"JKRichTextViewLinkBlockDataHandlerLinkPlaceholder";
static NSString * const JKRichTextViewLinkDidTappedCallbackAttributeName = @"JKRichTextViewLinkDidTappedCallbackAttributeName";
static NSString * const JKRichTextViewLinkDidLongPressCallbackAttributeName = @"JKRichTextViewLinkDidLongPressCallbackAttributeName";

@implementation JKRichTextViewLinkBlockDataHandler

+ (instancetype)sharedHandler {
    static JKRichTextViewLinkBlockDataHandler *_sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[[self class] alloc] init];
    });
    return _sharedHandler;
}

- (NSRegularExpression *)regularExpression {
    return nil;
}

- (BOOL)textView:(JKRichTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if(![[URL absoluteString] isEqualToString:JKRichTextViewLinkBlockDataHandlerLinkPlaceholder]) return NO;
    
    BOOL(^linkDidTappedCallbackBlock)(NSURL *linkURL) = [textView.attributedText attribute:JKRichTextViewLinkDidTappedCallbackAttributeName atIndex:characterRange.location effectiveRange:NULL];
    
    return linkDidTappedCallbackBlock(URL);
}

@end


@implementation JKRichTextView (CustomLinkCallBackConvenience)

- (void)setCustomLinkWithLinkDidTappedCallback:(BOOL (^)(NSURL *linkURL))didTappedCallback
                                forTextAtRange:(NSRange)textRange {
    
    [self setCustomLinkWithLinkDidTappedCallback:didTappedCallback
                            didLongPressCallback:nil
                                  forTextAtRange:textRange];
}

- (void)setCustomLinkWithLinkDidTappedCallback:(BOOL (^)(NSURL *linkURL))didTappedCallback
                          didLongPressCallback:(BOOL (^)(NSURL *linkURL))didLongPressCallback
                                forTextAtRange:(NSRange)textRange {
    
    NSParameterAssert(didTappedCallback || didLongPressCallback);
    
    [self setCustomLink:[NSURL URLWithString:JKRichTextViewLinkBlockDataHandlerLinkPlaceholder] forTextAtRange:textRange];
    
    [self addDataDetectionHandler:[JKRichTextViewLinkBlockDataHandler sharedHandler]];
    
    [self.textStorage beginEditing];
    [self.textStorage addAttribute:JKRichTextViewDetectedDataHandlerAttributeName value:NSStringFromClass([JKRichTextViewLinkBlockDataHandler class]) range:textRange];
    
    if(didTappedCallback) [self.textStorage addAttribute:JKRichTextViewLinkDidTappedCallbackAttributeName value:didTappedCallback range:textRange];
    if(didLongPressCallback) [self.textStorage addAttribute:JKRichTextViewLinkDidLongPressCallbackAttributeName value:didLongPressCallback range:textRange];
    
    [self.textStorage endEditing];
}

@end