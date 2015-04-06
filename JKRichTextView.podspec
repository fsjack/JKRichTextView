Pod::Spec.new do |s|

  s.name         = "JKRichTextView"
  s.version      = "0.0.1"
  s.summary      = "A more powerful UITextView."
  s.platform     = :ios
  s.ios.deployment_target = "7.0"

  s.homepage     = "https://github.com/fsjack/JKRichTextView"
  s.screenshots  = "https://github.com/fsjack/JKRichTextView/raw/master/banner.jpg"

  s.license      = "MIT"

  s.author             = { "Jackie" => "fsjack@gmail.com" }
  s.social_media_url   = "http://twitter.com/iamjackiecheung"

  s.source       = { :git => "https://github.com/fsjack/JKRichTextView.git", :tag => "0.0.1" }

  s.source_files  = "JKRichTextView/**/*.{h,m}"
  s.public_header_files = "JKRichTextView/**/*.h"
  s.requires_arc = true
  s.framework    = 'UIKit'

end
