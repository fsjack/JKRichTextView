//
//  ViewController.m
//  JKRichTextViewDemo
//
//  Created by Jackie CHEUNG on 15/3/23.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import "ViewController.h"
#import "JKRichTextViewLinkBlockDataHandler.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet JKRichTextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.textView setText:@"Mention @iamjackiecheung if you use JKRichTextView in your project[lol]. Thanks[cry]"];
    [self.textView setCustomLinkWithLinkDidTappedCallback:^BOOL (NSURL *linkURL) {
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Thank you for using JKRichTextView" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil] show];
        return YES;
        
    } forTextAtRange:[self.textView.text rangeOfString:@"JKRichTextView"]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.textView invalidateIntrinsicContentSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
