//
//  JKMyRichTextViewEmojiDataHandler.m
//  JKRichTextViewDemo
//
//  Created by Jackie CHEUNG on 15/4/6.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import "JKMyRichTextViewDataHandler.h"

@interface JKMyRichTextViewEmojiDataHandler ()
@end

@implementation JKMyRichTextViewEmojiDataHandler

- (NSDictionary *)configuration {
    static NSDictionary  *_configuration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"]];
    });
    return _configuration;
}

- (UIImage *)emojiImageForText:(NSString *)text {
    return [UIImage imageNamed:self.configuration[text]];
}

@end

@implementation JKRichTextViewMentionDataHandler

+ (instancetype)sharedHandler {
    static JKRichTextViewMentionDataHandler *_sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[JKRichTextViewMentionDataHandler alloc] init];
    });
    return _sharedHandler;
}

- (NSRegularExpression *)regularExpression {
    return JKAtMentionRegularExpression();
}

- (void)textView:(JKRichTextView *)textView didDetectedData:(JKRegularExpressionResult *)checkingResult {
    [textView setCustomLink:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://post?message=%@%%20Awesome!!!", checkingResult.result]] forTextAtRange:checkingResult.range];
}

@end


@implementation JKRichTextView (InterfaceBuilderExtension)

- (void)setParseEmotion:(BOOL)parseEmotion {
    if (parseEmotion) {
        [self addDataDetectionHandler:[JKMyRichTextViewEmojiDataHandler sharedHandler]];
    }
}

- (BOOL)parseEmotion {
    return [[self allDataDetectionHandlers] containsObject:[JKMyRichTextViewEmojiDataHandler sharedHandler]];
}

- (void)setParseMention:(BOOL)parseMention {
    if(parseMention)
        [self addDataDetectionHandler:[JKRichTextViewMentionDataHandler sharedHandler]];
}

- (BOOL)parseMention {
    return [[self allDataDetectionHandlers] containsObject:[JKRichTextViewMentionDataHandler sharedHandler]];
}

@end