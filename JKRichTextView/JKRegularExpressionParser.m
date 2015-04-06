//
//  WALinkParser.m
//
//  Created by Jackie on 12-11-10.
//  Copyright (c) 2012年 Jackie. All rights reserved.
//

#import "JKRegularExpressionParser.h"

#define JK_CREATE_CASE_INSENSITIVE_REGULAR_EXPRESSION(name, expression) JK_CREATE_REGULAR_EXPRESSION(name, expression, NSRegularExpressionCaseInsensitive)

#define JK_CREATE_REGULAR_EXPRESSION(name, expression, option) \
inline NSRegularExpression *name() { \
    static NSRegularExpression * _name = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        NSError *error = nil; \
        _name = [[NSRegularExpression alloc] initWithPattern:expression options:option error:&error]; \
        if(error) NSLog(@"[ERROR] Something worng with regular expressoin syntax:\n%@", error);\
    }); \
    return _name; \
} \

JK_CREATE_CASE_INSENSITIVE_REGULAR_EXPRESSION(JKLinkRegularExpression, @"[a-zA-Z]+://[0-9a-zA-Z_.?&/=]+")
JK_CREATE_CASE_INSENSITIVE_REGULAR_EXPRESSION(JKAtMentionRegularExpression, @"@[^\\s:：,，@]+$?");
JK_CREATE_CASE_INSENSITIVE_REGULAR_EXPRESSION(JKHashTagRegularExpression, @"#.+?#")
JK_CREATE_CASE_INSENSITIVE_REGULAR_EXPRESSION(JKBracketRegularExpression, @"\\[\\w+\\]");
JK_CREATE_CASE_INSENSITIVE_REGULAR_EXPRESSION(JKEmailRegularExpression, @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+");
JK_CREATE_REGULAR_EXPRESSION(JKEmojiRegularExpression, @"[\u00A9\u00AE\u2002\u2003\u2005\u203C\u2049\u2122\u2139\u2194\u2195\u2196\u2197\u2198\u2199\u21A9\u21AA\u231A\u231B\u23E9\u23EA\u23EB\u23EC\u23F0\u23F3\u24C2\u25AA\u25AB\u25B6\u25C0\u25FB\u25FC\u25FD\u25FE\u2600\u2601\u260E\u2611\u2614\u2615\u261D\u263A\u2648\u2649\u264A\u264B\u264C\u264D\u264E\u264F\u2650\u2651\u2652\u2653\u2660\u2663\u2665\u2666\u2668\u267B\u267F\u2693\u26A0\u26A1\u26AA\u26AB\u26BD\u26BE\u26C4\u26C5\u26CE\u26D4\u26EA\u26F2\u26F3\u26F5\u26FA\u26FD\u2702\u2705\u2708\u2709\u270A\u270B\u270C\u270F\u2712\u2714\u2716\u2728\u2733\u2734\u2744\u2747\u274C\u274E\u2753\u2754\u2755\u2757\u2764\u2795\u2796\u2797\u27A1\u27B0\u2934\u2935\u2B05\u2B06\u2B07\u2B1B\u2B1C\u2B50\u2B55\u3030\u303D\u3297\u3299\U0001F100-\U0001F6FF]", NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines)

@implementation JKRegularExpressionResult

+ (JKRegularExpressionResult *)resultWithExpression:(NSRegularExpression *)regularExpression range:(NSRange)range result:(NSString *)result {
    JKRegularExpressionResult *expressionResult = [[JKRegularExpressionResult alloc] init];
    
    expressionResult->_regularExpression = regularExpression;
    expressionResult->_result = [result copy];
    expressionResult->_range = range;
    
    return expressionResult;
}

@end

@interface JKRegularExpressionParser ()
@end

@implementation JKRegularExpressionParser
#pragma mark - methods
+ (void)enumerateMatchesInString:(NSString *)string withRegularExpressions:(NSArray *)regularExpressions options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(JKRegularExpressionResult *result, NSMatchingFlags flags, BOOL *stop))block{
    
    [regularExpressions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        __block NSRegularExpression *regularExpression = (NSRegularExpression *)obj;
        [regularExpression enumerateMatchesInString:string options:options range:range usingBlock:^(NSTextCheckingResult *textCheckingResult, NSMatchingFlags flags, BOOL *stop){
            
            if(!textCheckingResult) return ;
            NSString *matchedString = [string substringWithRange:textCheckingResult.range];
            
            JKRegularExpressionResult *checkingResult = [JKRegularExpressionResult resultWithExpression:regularExpression range:textCheckingResult.range result:matchedString];
            if(block) block(checkingResult, flags, stop);
        }];
    }];
}

+ (NSArray *)matchesInString:(NSString *)string withRegularExpressions:(NSArray *)regularExpressions options:(NSMatchingOptions)options range:(NSRange)range {
    NSMutableArray *resultArray = [NSMutableArray array];
    [self enumerateMatchesInString:string withRegularExpressions:regularExpressions options:options range:range usingBlock:^(JKRegularExpressionResult *result, NSMatchingFlags flags, BOOL *stop){
        [resultArray addObject:result];
    }];
    
    return [resultArray copy];
}

+ (NSUInteger)numberOfMatchesInString:(NSString *)string withRegularExpressions:(NSArray *)regularExpressions options:(NSMatchingOptions)options range:(NSRange)range {
    __block int matchesCount = 0;
    [regularExpressions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSRegularExpression *regularExpression = (NSRegularExpression *)obj;
        matchesCount += [regularExpression numberOfMatchesInString:string options:options range:range];
    }];
    
    return matchesCount;
}
@end