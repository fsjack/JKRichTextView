//
//  WALinkParser.h
//
//  Created by Jackie on 12-11-10.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    Some common regular expressions.
 */
// Extract text like http://www.fsjack.com.
extern NSRegularExpression *JKLinkRegularExpression();

//Extract text like fsjack@gmail.com
extern NSRegularExpression *JKEmailRegularExpression();

//Extract text like @Jackie_CHEUNG. stop when meet space.
extern NSRegularExpression *JKAtMentionRegularExpression();

//Extract text like #JKRichTextView. stop when meet space.
extern NSRegularExpression *JKHashTagRegularExpression();

//Extract text like [LOL] or [Laungh]
extern NSRegularExpression *JKBracketRegularExpression();

//Extract text like 😀.
extern NSRegularExpression *JKEmojiRegularExpression();


@interface JKRegularExpressionResult : NSObject

@property (nonatomic, readonly)         NSRange range;
@property (nonatomic, readonly, copy)   NSString *result;
@property (nonatomic, readonly, strong) NSRegularExpression *regularExpression;

+ (JKRegularExpressionResult *)resultWithExpression:(NSRegularExpression *)regularExpression range:(NSRange)range result:(NSString *)result;

@end

@interface JKRegularExpressionParser : NSObject

+ (NSUInteger)numberOfMatchesInString:(NSString *)string withRegularExpressions:(NSArray *)regularExpressions options:(NSMatchingOptions)options range:(NSRange)range;

+ (NSArray *)matchesInString:(NSString *)string withRegularExpressions:(NSArray *)regularExpressions options:(NSMatchingOptions)options range:(NSRange)range;

+ (void)enumerateMatchesInString:(NSString *)string withRegularExpressions:(NSArray *)regularExpressions options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(JKRegularExpressionResult *result, NSMatchingFlags flags, BOOL *stop))block;

@end