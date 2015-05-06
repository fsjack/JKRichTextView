//
//  WARickTextView.h
//  Pods
//
//  Created by Jackie CHEUNG on 14-6-2.
//
//

#import <UIKit/UIKit.h>

#import "JKRegularExpressionParser.h"

@class JKRichTextView;
/**
    A Data Detecetion Handler is actually a module for JKRichTextView to handle certain regular expression.
    Conforming this protocol and asking JKRichTextView instance to add it as one of the handler, JKRichTextView will automatically call optional portocol methods after parsing the regular expression.
    A example of custom RichTextViewDataDetectionHandler:
 
    //ViewController.m
    - (void) viewDidLoad {
        [super ViewDidLoad];
        [self.textView addDataDetectionHandler:[[JKCustomRichTextViewDataDetectionHandler alloc] init]];
    }
 
    //JKCustomRichTextViewDataDetectionHandler.h
    @interface JKCustomRichTextViewDataDetectionHandler : NSObject<JKRichTextViewDataDetectionHandler>
    @end
 
    //JKCustomRichTextViewDataDetectionHandler.m
    @implementation JKCustomRichTextViewDataDetectionHandler
 
    - (NSRegularExpression *)regularExpression {
        return JKLinkRegularExpression();
    }
 
    - (void)textView:(JKRichTextView *)textView didDetectedData:(JKRegularExpressionResult *)checkingResult {
        // Do your work here.
    }
    @end
 
 */
@protocol JKRichTextViewDataDetectionHandler <NSObject>
@required
/**
    DO NOT dynamicatily create regularExpression instance. use a STATIC regularExpression as output.
    Example:
    - (NSRegularExpression *)regularExpression {
        static NSRegularExpression *_regularExpression = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _regularExpression = [[NSRegularExpression alloc] initWithPattern:pattern options:option error:nil];
        });
        return _regularExpression;
    }
 */
@property (nonatomic, readonly) NSRegularExpression *regularExpression;

@optional

/**
    RichTextView parse text when scrollView stop scrolling, not turely asynchronized. Will add later.
 */
@property (nonatomic, readonly) BOOL detectionAsynchronized;

/**
    Get called when the text is finish parsed.
 */
- (void)textView:(JKRichTextView *)textView didDetectData:(JKRegularExpressionResult *)checkingResult;

/**
    Return YES will stop calling textView:didDetectData:.
 */
- (BOOL)textView:(JKRichTextView *)textView shouldStopDetectingData:(JKRegularExpressionResult *)checkingResult;

/**
    handle the URL action here.
 */
- (BOOL)textView:(JKRichTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange;

/**
    Return NO if the parsed result is not touchable.
 */
- (BOOL)textView:(JKRichTextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange;

@end


extern NSString * const JKRichTextViewDetectedDataHandlerAttributeName;

@interface JKRichTextView : UITextView

- (NSArray *)allDataDetectionHandlers;

- (void)addDataDetectionHandler:(id<JKRichTextViewDataDetectionHandler>)handler;

- (void)removeDataDetectionHandler:(id<JKRichTextViewDataDetectionHandler>)handler;

/**
    TextView could automatically detect links when you're typing.
 */
@property (nonatomic) BOOL shouldAutoDetectDataWhileEditing;
/**
    When you put textview on some view, like UITableViewCell, you will found out the cell is totally untouable because UITextView's UserInteractiveEnabled enabled. And you cannot change this property since you need to interact with UITextView, So shouldPassthoughUntouchableText could makes TextView to be transparent to the cell but not to the links. You can still tap the link and you can tap the cell as well. Default is NO.
    @WARNING If you make your text editable, you MUST turn this off otherwise you cannot edit textView normally!!!
 */
@property (nonatomic) BOOL shouldPassthoughUntouchableText;

/**
    Make UITextView's default attributes won't be affect by attributedText.
    UITextView's text color, font, text alighment will actually change corresponding to the changing on attributedText.Which makes UITextView unreuseable because when you set different text for text view, it won't reset it's attribute. Setting defaultAttributesUnaffectable can prevent this happening.
    Default is NO.
 */
@property (nonatomic) BOOL defaultAttributesUnaffectable;

@end

@interface JKRichTextView (Formation)

- (void)setCustomLink:(NSURL *)url forTextAtRange:(NSRange)textRange;

- (void)insertImage:(UIImage *)image size:(CGSize)size atIndex:(NSUInteger)index;

- (void)insertTextAttachment:(NSTextAttachment *)attachment atIndex:(NSUInteger)index;

- (void)insertTextAttachment:(NSTextAttachment *)attachment atIndex:(NSUInteger)index baselineAjustment:(BOOL)baselineAjustment;

- (void)replaceCharacterAtRange:(NSRange)textRange withTextAttachment:(NSTextAttachment *)attachment;

- (void)replaceCharacterAtRange:(NSRange)textRange withTextAttachment:(NSTextAttachment *)attachment baselineAjustment:(BOOL)baselineAjustment;

@end