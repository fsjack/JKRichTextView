//
//  JKRichTextViewEmojiDataHandler.h
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-2.
//
//

#import <Foundation/Foundation.h>
#import "JKRichTextView.h"

/**
    Handle the emotion text like [laungh] or [cry], Subclass this class and override emojiImageForText: and provide your own emoji image for emotion text.
 */
@interface JKRichTextViewEmojiDataHandler : NSObject <JKRichTextViewDataDetectionHandler>

+ (instancetype)sharedHandler;

/**
    Return image for data detection result.
    Overriden this method to return your own emoji image. Default implementation return nil.
 */
- (UIImage *)emojiImageForText:(NSString *)text;

/**
    Make emoji image size fit to font point size.
    Default is YES
 */
@property (nonatomic) BOOL adjustEmojiImageSizeFitToFontSize;

@end
