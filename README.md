![](banner.jpg)

JKRichTextView can handle image and add link with block.

## Installation
### CocoaPods

	pod 'JKRichTextView'
	
## Usage	
### Insert Image
import `<JKRichTextView/JKRichTextView.h>` first.

	[textView insertImage:[UIImage imageNamed:@"JKRichTextView"] size:CGSizeMake(280, 293) atIndex:0];
	
### Add custom link with block
import `<JKRichTextView/JKRichTextViewLinkBlockDataHandler.h>` first.
	
	[textView setCustomLinkWithLinkDidTappedCallback:^BOOL (NSURL *linkURL) {
        //Do something
        return YES;
    } forTextAtRange:[self.textView.text rangeOfString:@"Link"]];

### Parse emotion text
JKRichTextView can also parse text like [lol] or [cry], and turn it into image.
Check the demo project.

### @name or #hashtag
Just implement your own DataDetectionHandler, just check demo for example.

### REALTIME detect links support
JKRichTextView can automatically detects emotion text, @name, hashtag or links when you're typing in realtime.

## Change Log
* Add auto detecting links REALTIME when you're editing the text.

## License
	The MIT License (MIT)
	
	Copyright © 2015 Jackie
	
	Permission is hereby granted free of charge to any person obtaining a copy of this software and associated documentation files (the "Software") to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
