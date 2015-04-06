//
//  JKRichTextViewLinkBlockDataHandler.h
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-7.
//
//

#import <Foundation/Foundation.h>
#import "JKRichTextView.h"


/**
    DO NOT add this handler to your textView directly. use CustomLinkCallBackConvenience methods instead.
 */
@interface JKRichTextViewLinkBlockDataHandler : NSObject <JKRichTextViewDataDetectionHandler>
+ (instancetype)sharedHandler;
@end


@interface JKRichTextView (CustomLinkCallBackConvenience)

- (void)setCustomLinkWithLinkDidTappedCallback:(BOOL (^)(NSURL *linkURL))didTappedCallback
                                forTextAtRange:(NSRange)textRange;

- (void)setCustomLinkWithLinkDidTappedCallback:(BOOL (^)(NSURL *linkURL))didTappedCallback
                          didLongPressCallback:(BOOL (^)(NSURL *linkURL))didLongPressCallback
                                forTextAtRange:(NSRange)textRange;

@end