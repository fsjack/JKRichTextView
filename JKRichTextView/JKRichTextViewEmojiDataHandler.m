//
//  JKRichTextViewEmojiDataHandler.m
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-2.
//
//

#import "JKRichTextViewEmojiDataHandler.h"
#import "JKRegularExpressionParser.h"

@implementation JKRichTextViewEmojiDataHandler

+ (instancetype)sharedHandler {
    static id _sharedHandler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHandler = [[[self class] alloc] init];
    });
    return _sharedHandler;
}

- (id)init {
    self = [super init];
    if(self) {
        self.adjustEmojiImageSizeFitToFontSize = YES;
    }
    return self;
}

- (UIImage *)emojiImageForText:(NSString *)text {
    return nil;
}

- (void)textView:(JKRichTextView *)textView didDetectData:(JKRegularExpressionResult *)checkingResult {
    
    UIImage *emojiImage = [self emojiImageForText:checkingResult.result];
    
    if(!emojiImage) {
        NSLog(@"[WARNING] JKRichTextViewEmojiDataHandler cannot find emoji image for text: %@. Please take a look at JKRichTextViewEmojiDataHandler for more detail.", checkingResult.result);
        return;
    }
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    attachment.image = emojiImage;
    
    if(self.adjustEmojiImageSizeFitToFontSize) {
        UIFont *font = [textView.attributedText attribute:NSFontAttributeName atIndex:checkingResult.range.location effectiveRange:NULL];
        
        CGFloat emojiimageSizeHeight = ABS(font.ascender) + ABS(font.descender);
        CGFloat emojiImageSizeWidth = (emojiimageSizeHeight / emojiImage.size.height) * emojiImage.size.width;
        
        attachment.bounds = CGRectMake(0, 0, emojiImageSizeWidth, emojiimageSizeHeight);
    }
    
    [textView replaceCharacterAtRange:checkingResult.range withTextAttachment:attachment baselineAjustment:YES];
}

- (NSRegularExpression *)regularExpression {
    return JKBracketRegularExpression();
}

- (BOOL)textView:(JKRichTextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    return NO;
}

@end
