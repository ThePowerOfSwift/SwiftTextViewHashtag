# SwiftTextViewHashtag
Hash tag detection for TextViews in Swift

## Overview

This is a quick and dirty sample project implementing Hashtag detection

![animated gif demo](https://github.com/ThornTechPublic/SwiftTextViewHashtag/blob/master/GitHubImages/hashVideo.gif)

## Installation / Integration

To use this in your own app, just copy the [UITextField+Extension.swift](https://github.com/ThornTechPublic/SwiftTextViewHashtag/blob/master/textViewSample/UITextField%2BExtension.swift) file into your project.

You may want to further [customize this section of code](https://github.com/ThornTechPublic/SwiftTextViewHashtag/blob/master/textViewSample/UITextField%2BExtension.swift#L27) with a TextView font and color that fits your app's style guide, because the Storyboard attributes get overridden.

## Usage

To detect hashtags in your textViews:

1. Make sure the UITextView is `selectable`, can detect `links`, and is not `editable` (see image below)
1. Wire the UITextView delegate to your ViewController
1. Implement the UITextViewDelegate method `textView:shouldInteractWithURL:` to hook into the URL tap.  [See example](https://github.com/ThornTechPublic/SwiftTextViewHashtag/blob/master/textViewSample/ViewController.swift#L164).
1. After you set the text, call the `resolveHashTags()` method.  [See example](https://github.com/ThornTechPublic/SwiftTextViewHashtag/blob/master/textViewSample/TextCell.swift#L17)

![screenshot from storyboard](https://github.com/ThornTechPublic/SwiftTextViewHashtag/blob/master/GitHubImages/UITextViewStoryboard.png)

## How it works

The approach used here is to add an attribute (much like an "href") to hashtagged words.  

### URL detection

Hashtag detection builds upon URL detection.  This is why the TextView is setup to detect links.  Note that links are only clickable when `Editable` is unchecked.

At this point, URLs in the textview will open in the Safari app.

### Add link attributes

Next, an "href" attribute is added to each hashtagged word.  

The overall process goes something like this:
* Iterate over each word and look for anything that starts with `#`
* Chop off the first character `#`.  For example, `#helloWorld` becomes `helloWorld`
* Create a fake URL using a fake URL scheme.  For example, `hash:helloWorld`
* Associate this fake URL with the hashtag word.  `NSMutableAttributedString` has APIs to accomplish this.

[Here's the code](https://github.com/ribl/SwiftTextViewHashtag/blob/master/textViewSample/UITextField%2BExtension.swift#L13)

### Clicking on hashtags

Now that hashtags are URLs, they are a different color and can be clicked.  Note: it's tempting to add a tap gesture to TextView, but you can leverage the built-in delegate instead.

Intercept the URL click and check for your fake URL scheme.  
* Set the TextView delegate.  
* Implement the `UITextFieldDelegate` which has a `shouldInteractWithURL` method 
* Check for your fake `URL.scheme` 
* Grab the payload in the `URL.resourceSpecifier`

[Here's the code](https://github.com/ThornTechPublic/SwiftTextViewHashtag/blob/master/textViewSample/ViewController.swift#L164)

## Other resources

* [STTweetLabel](https://github.com/SebastienThiebaud/STTweetLabel), an Objective-C CocoaPod for hashtag detection
* A [swift implementation](https://yeti.co/blog/hashtags-and-mentions/) of hashtags and mentions.  I wish this was available when I first implemented hashtags.  Their approach is slightly different though.  
* I used [this](http://kishikawakatsumi.hatenablog.com/entry/20130605/1370370925) to initially figure out my approach.  You might need to click "translate from japanese" on the top.
* I used [this](http://stackoverflow.com/questions/11547919/check-if-string-contains-a-hashtag-and-then-change-hashtag-color) to figure out how to use `NSMutableAttributedString`
* [Ray Wenderlich Scroll View](http://www.raywenderlich.com/video-tutorials#swiftscrollview) video series helped me understand keyboard movement in the example project.
