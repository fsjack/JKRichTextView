//
//  JKRichTextView.m
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-2.
//
//

#import "JKRichTextView.h"
#import "JKRegularExpressionParser.h"
#import "JKDelegateProxy.h"

NSString * const JKRichTextViewDetectedDataHandlerAttributeName = @"JKRichTextViewDetectedDataHandlerAttributeName";

static CGSize const JKRichTextViewInvalidedIntrinsicContentSize = (CGSize){-1, -1};

@class JKRichTextViewDelegateHandler;
@interface JKRichTextView ()
@property (nonatomic, strong) NSMutableArray *dataDetectionHandlers;
@property (nonatomic, strong) JKDelegateProxy *delegateProxy;
@property (nonatomic, strong) JKRichTextViewDelegateHandler *delegateHandler;

@property (nonatomic) CGSize intrinsicContentSize;

@property (nonatomic, strong) NSMutableDictionary *defaultTypingAttributes;
@end

@interface JKRichTextViewDelegateHandler : NSObject<UITextViewDelegate>
@property (nonatomic, weak) JKRichTextView *textView;
@end

@implementation JKRichTextView
#pragma mark - Init
- (id)init {
    self = [super init];
    if(self) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if(self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    [super setDelegate:(id <UITextViewDelegate>)self.delegateProxy];
    self.shouldPassthoughUntouchableText = YES;
    self.shouldAutoDetectDataWhileEditing = YES;
}


#pragma mark -

- (JKRichTextViewDelegateHandler *)delegateHandler {
    if (!_delegateHandler) {
        _delegateHandler = [[JKRichTextViewDelegateHandler alloc] init];
        _delegateHandler.textView = self;
    }
    return _delegateHandler;
}

- (JKDelegateProxy *)delegateProxy {
    if (!_delegateProxy) {
        _delegateProxy = [[JKDelegateProxy alloc] initWithDelegateProxy:self.delegateHandler];
    }
    return _delegateProxy;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    
    if(delegate == self.delegateProxy) return;
    
    [self.delegateProxy removeDelegateTarget:[self.delegateProxy allDelegateTargets].lastObject];
    if(delegate) [self.delegateProxy addDelegateTarget:delegate];
    
    [super setDelegate:(id<UITextViewDelegate>)self.delegateProxy];
}

- (NSMutableDictionary *)defaultTypingAttributes {
    if (!_defaultTypingAttributes) {
        _defaultTypingAttributes = [NSMutableDictionary dictionary];
    }
    return _defaultTypingAttributes;
}

#pragma mark -

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.defaultTypingAttributes[NSFontAttributeName] = font;
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    self.defaultTypingAttributes[NSForegroundColorAttributeName] = textColor;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = textAlignment;
    self.defaultTypingAttributes[NSParagraphStyleAttributeName] = [paragraphStyle copy];
}

- (void)resetTypingAttributes {
    self.typingAttributes = [self.defaultTypingAttributes copy];
}

- (void)setText:(NSString *)text {
    if(self.defaultAttributesUnaffectable) [self resetTypingAttributes];
    [super setText:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    
    self.intrinsicContentSize = JKRichTextViewInvalidedIntrinsicContentSize;
    [super setAttributedText:attributedText];
    [self startDataDetection];
}

- (NSMutableArray *)dataDetectionHandlers {
    if (!_dataDetectionHandlers) {
        _dataDetectionHandlers = [NSMutableArray array];
    }
    return _dataDetectionHandlers;
}

- (NSArray *)allDataDetectionHandlers {
    return [self.dataDetectionHandlers copy];
}

- (void)addDataDetectionHandler:(id<JKRichTextViewDataDetectionHandler>)handler {
    NSAssert([handler conformsToProtocol:@protocol(JKRichTextViewDataDetectionHandler)], @"[ERROR] handler MUST confirm to 'JKRichTextViewDataDetectionHandler' Protocol.");
    
    if([handler conformsToProtocol:@protocol(JKRichTextViewDataDetectionHandler)] && ![self.dataDetectionHandlers containsObject:handler])
        [self.dataDetectionHandlers addObject:handler];
}

- (void)removeDataDetectionHandler:(id<JKRichTextViewDataDetectionHandler>)handler {
    [self.dataDetectionHandlers removeObject:handler];
}

- (void)startDataDetection {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    for (id<JKRichTextViewDataDetectionHandler>handler in self.allDataDetectionHandlers) {
        if([handler respondsToSelector:@selector(detectionAsynchronized)] && handler.detectionAsynchronized)
            [self performSelector:@selector(startDataDetectionWithHandler:) withObject:handler afterDelay:0];
        else
            [self startDataDetectionWithHandler:handler];
    }
}

- (void)startDataDetectionWithHandler:(id<JKRichTextViewDataDetectionHandler>) handler{
    
    if(!handler.regularExpression) return;
    
    __weak __typeof(&*self)weakSelf = self;
    [JKRegularExpressionParser enumerateMatchesInString:self.text
                                   withRegularExpressions:@[handler.regularExpression]
                                     options:NSMatchingReportCompletion
                                       range:NSMakeRange(0, self.text.length)
                                  usingBlock:^(JKRegularExpressionResult *result, NSMatchingFlags flags, BOOL *stop) {
                                      
                                      [handler textView:weakSelf didDetectedData:result];
                                      
                                      [weakSelf.textStorage beginEditing];
                                      [weakSelf.textStorage addAttribute:JKRichTextViewDetectedDataHandlerAttributeName
                                                            value:NSStringFromClass([handler class])
                                                            range:result.range];
                                      [weakSelf.textStorage endEditing];
                                      
                                      if([handler respondsToSelector:@selector(textView:shouldStopDetecteData:)])
                                          *stop = [handler textView:weakSelf shouldStopDetecteData:result];
                                  }];
    
}

- (void)invalidateIntrinsicContentSize {
    [super invalidateIntrinsicContentSize];
    _intrinsicContentSize = JKRichTextViewInvalidedIntrinsicContentSize;
}

- (CGSize)intrinsicContentSize {
    if(CGSizeEqualToSize(_intrinsicContentSize, JKRichTextViewInvalidedIntrinsicContentSize)) {
        CGSize intrinsicContentSize = [self sizeThatFits:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
        _intrinsicContentSize = intrinsicContentSize;
    }
    return _intrinsicContentSize;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = [super pointInside:point withEvent:event];
    
    if(!self.shouldPassthoughUntouchableText || !pointInside) return pointInside;
    
    NSUInteger characterIndex = [self.layoutManager characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    
    NSURL *linkURL = [self.attributedText attribute:NSLinkAttributeName atIndex:characterIndex effectiveRange:NULL];
    
    pointInside = linkURL ? YES : NO;
    
    return pointInside;
}

@end


@implementation JKRichTextView (Formation)

- (void)setCustomLink:(NSURL *)url forTextAtRange:(NSRange)textRange {
    NSParameterAssert(url);
    
    if(self.text.length < NSMaxRange(textRange)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"[ERROR] JKRichTextView Cannot set custom link because text range(%@) is out of range.", NSStringFromRange(textRange)]}];
        return;
    }
    
    [self.textStorage beginEditing];
    [self.textStorage addAttribute:NSLinkAttributeName value:url range:textRange];
    [self.textStorage endEditing];
}

- (void)insertImage:(UIImage *)image size:(CGSize)size atIndex:(NSUInteger)index {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, size.width, size.height);
    
    [self insertTextAttachment:attachment atIndex:index baselineAjustment:YES];
}

- (void)insertTextAttachment:(NSTextAttachment *)attachment atIndex:(NSUInteger)index {
    [self insertTextAttachment:attachment atIndex:index baselineAjustment:NO];
}

- (void)insertTextAttachment:(NSTextAttachment *)attachment atIndex:(NSUInteger)index baselineAjustment:(BOOL)baselineAjustment {
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [self insertTextAttachment:attachment forAttributedText:attributedText atIndex:index baselineAjustment:baselineAjustment];
    [super setAttributedText:attributedText];
}

- (void)insertTextAttachment:(NSTextAttachment *)attachment forAttributedText:(NSMutableAttributedString *)attributedText atIndex:(NSUInteger)index baselineAjustment:(BOOL)baselineAjustment {
    NSParameterAssert(attachment);
    
    NSAttributedString *imageAttributeString = [NSAttributedString attributedStringWithAttachment:attachment];
    [attributedText insertAttributedString:imageAttributeString atIndex:index];
    
    if(baselineAjustment && self.text.length >= index+1) {
        /** Adjust attribute text baseline offset, because attachment image will be inserted above baseline.  */
        UIFont *font = [attributedText attribute:NSFontAttributeName atIndex:index effectiveRange:NULL];
        [attributedText addAttribute:NSBaselineOffsetAttributeName value:@(font.descender) range:NSMakeRange(index, 1)];
    }
}

- (void)replaceCharacterAtRange:(NSRange)textRange withTextAttachment:(NSTextAttachment *)attachment {
    [self replaceCharacterAtRange:textRange withTextAttachment:attachment baselineAjustment:NO];
}

- (void)replaceCharacterAtRange:(NSRange)textRange withTextAttachment:(NSTextAttachment *)attachment baselineAjustment:(BOOL)baselineAjustment {
    NSParameterAssert(attachment);
    
    NSMutableString *replacementString = [NSMutableString string];
    
    NSString *attachmentReplacementString = [NSString stringWithFormat:@"%C", (unichar)NSAttachmentCharacter];
    for (NSUInteger index = 0; index < textRange.length-1; index++) [replacementString appendString:attachmentReplacementString];
    
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:textRange withString:replacementString];
    
    [self insertTextAttachment:attachment forAttributedText:self.textStorage atIndex:textRange.location baselineAjustment:baselineAjustment];
    [self.textStorage endEditing];
}

@end


@implementation JKRichTextViewDelegateHandler
#pragma mark - UITextvViewDelegate
- (BOOL)textView:(JKRichTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    NSString *handlerClassName = [textView.attributedText attribute:JKRichTextViewDetectedDataHandlerAttributeName atIndex:characterRange.location effectiveRange:nil];
    
    if(!handlerClassName.length) return YES;
    
    for (id<JKRichTextViewDataDetectionHandler> handler in self.textView.dataDetectionHandlers) {
        
        if(![NSStringFromClass([handler class]) isEqualToString:handlerClassName]) continue;
        if([handler respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
            [handler textView:textView shouldInteractWithURL:URL inRange:characterRange];
        else
            [[UIApplication sharedApplication] openURL:URL];
    }
    return NO;
}

- (BOOL)textView:(JKRichTextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    
    NSString *handlerClassName = [textView.attributedText attribute:JKRichTextViewDetectedDataHandlerAttributeName atIndex:characterRange.location effectiveRange:nil];
    
    for (id<JKRichTextViewDataDetectionHandler> handler in self.textView.dataDetectionHandlers) {
        
        if(![NSStringFromClass([handler class]) isEqualToString:handlerClassName]) continue;
        if([handler respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) [handler textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    if(self.textView.shouldAutoDetectDataWhileEditing) [self.textView startDataDetection];
}

@end

