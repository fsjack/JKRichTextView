//
//  JKMyRichTextViewEmojiDataHandler.h
//  JKRichTextViewDemo
//
//  Created by Jackie CHEUNG on 15/4/6.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import "JKRichTextViewEmojiDataHandler.h"

@interface JKMyRichTextViewEmojiDataHandler : JKRichTextViewEmojiDataHandler
@end

@interface JKRichTextViewMentionDataHandler : NSObject <JKRichTextViewDataDetectionHandler>
@end


@interface JKRichTextView (InterfaceBuilderExtension)

@property (nonatomic) IBInspectable BOOL parseEmotion;
@property (nonatomic) IBInspectable BOOL parseMention;

@end