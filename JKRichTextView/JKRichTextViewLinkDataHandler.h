//
//  JKRichTextViewLinkDataHandler.h
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-2.
//
//

#import <Foundation/Foundation.h>
#import "JKRichTextView.h"
/*
    Handle common links like ftp://address or http://www.facebook.com. You can sublcass this handler and override URLForCheckingResult: to provide your own link.
 */
@interface JKRichTextViewLinkDataHandler : NSObject <JKRichTextViewDataDetectionHandler>

+ (instancetype)sharedHandler;

/**
    Return link url for data detection result.
    Overriden this method to return your own link. Default implementation just return the result as link.
 */
- (NSURL *)URLForCheckingResult:(JKRegularExpressionResult *)result;

@end
