//
//  JKRichTextViewLinkDataHandler.m
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-2.
//
//

#import "JKRichTextViewLinkDataHandler.h"
#import "JKRegularExpressionParser.h"

@implementation JKRichTextViewLinkDataHandler

+ (instancetype)sharedHandler {
    static id _sharedHandler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[[self class] alloc] init];
    });
    return _sharedHandler;
}

- (NSRegularExpression *)regularExpression {
    return JKLinkRegularExpression();
}

- (NSURL *)URLForCheckingResult:(JKRegularExpressionResult *)result {
    return [NSURL URLWithString:result.result];
}

- (void)textView:(JKRichTextView *)textView didDetectData:(JKRegularExpressionResult *)checkingResult {
    NSURL *customLinkURL = [self URLForCheckingResult:checkingResult];
    NSAssert(customLinkURL, @"[ERROR] TextView unable to set Nil custom URL link.");
    
    if(customLinkURL) {
        if([self detectionAsynchronized]) {
            CATransition *animation = [CATransition animation];
            animation.type = kCATransitionFade;
            animation.duration = 0.2f;
            [textView.layer addAnimation:animation forKey:@"Fade"];
        }
        [textView setCustomLink:customLinkURL forTextAtRange:checkingResult.range];
    }
}

- (BOOL)textView:(JKRichTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [[UIApplication sharedApplication] openURL:URL];
    return NO;
}

@end
