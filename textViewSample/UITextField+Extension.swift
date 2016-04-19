//
//  UITextField+Extension.swift
//  textViewSample
//
//  Created by Robert Chen on 5/22/15.
//  Copyright (c) 2015 Thorn Technologies. All rights reserved.
//

import UIKit

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

extension UITextView {
    
    public func resolveHashTags() {
        
        let schemeMap = [
            "#":"hash",
            "@":"mention"
        ]
        
        let nsText:NSString = self.text
        
        // Separate the string into individual words.
        // Whitespace is used as the word boundary.
        // You might see word boundaries at special characters, like before a period.
        // But we need to be careful to retain the # or @ characters.
        let words:[NSString] = nsText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        
        
        let fullRange = NSRange(location: 0, length: attributedText.length)
        var attributes = [String:AnyObject]()
        
        attributedText.enumerateAttributesInRange(fullRange, options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (existingAttributes:[String : AnyObject], range:NSRange, ptr:UnsafeMutablePointer<ObjCBool>) in
            attributes += existingAttributes
        }
        
        // Use an Attributed String to hold the text and fonts from above.
        // We'll also append to this object some hashtag URLs for specific word ranges.
        let attrString = NSMutableAttributedString(string: nsText as String, attributes:attributes)
        
        // keep track of where we are as we interate through the string.
        // otherwise, a string like "#test #test" will only highlight the first one.
        var bookmark = 0
        
        // Iterate over each word.
        // So far each word will look like:
        // - I
        // - visited
        // - #123abc.go!
        // The last word is a hashtag of #123abc
        // Use the following hashtag rules:
        // - Include the hashtag # in the URL
        // - Only include alphanumeric characters.  Special chars and anything after are chopped off.
        // - Hashtags can start with numbers.  But the whole thing can't be a number (#123abc is ok, #123 is not)
        for word in words {
            
            var scheme:String? = nil
            
            if word.hasPrefix("#") {
                scheme = schemeMap["#"]
            } else if word.hasPrefix("@") {
                scheme = schemeMap["@"]
            }
            
            // found a word that is prepended by a hashtag
            if let scheme = scheme {
                
                // convert the word from NSString to String
                // this allows us to call "dropFirst" to remove the hashtag
                var stringifiedWord:String = word as String
                
                // example: #123abc.go!
                
                // remember the first character, such as "#"
                let prefix = Array(stringifiedWord.characters)[0]
                
                // drop the hashtag
                // example becomes: 123abc.go!
                stringifiedWord = String(stringifiedWord.characters.dropFirst())
                
                // Chop off special characters and anything after them.
                // example becomes: 123abc
                stringifiedWord = chopOffNonAlphaNumericCharacters(stringifiedWord)
                
                if let _ = Int(stringifiedWord) {
                    // don't convert to hashtag if the entire string is numeric.
                    // example: 123abc is a hashtag
                    // example: 123 is not
                } else if stringifiedWord.isEmpty {
                    // do nothing.
                    // the word was just the hashtag by itself.
                } else {
                    // stick the prefix back on, but only to find the location. i.e. #123abc
                    let prefixedWord = "\(prefix)\(stringifiedWord)"
                    // find out where #123abc appears in the string.
                    // only search the section of the string we haven't iterated over yet
                    let remainingRange = NSRange(location: bookmark, length: (nsText.length - bookmark))
                    let matchRange:NSRange = nsText.rangeOfString(prefixedWord, options: NSStringCompareOptions.LiteralSearch, range:remainingRange)
                    
                    // URL syntax is http://123abc
                    
                    // Replace custom scheme with something like hash://123abc
                    // URLs actually don't need the forward slashes, so it becomes hash:123abc
                    // Custom scheme for @mentions looks like mention:123abc
                    // As with any URL, the string will have a blue color and is clickable
                    if let escapedString = stringifiedWord.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
                        attrString.addAttribute(NSLinkAttributeName, value: "\(scheme):\(escapedString)", range: matchRange)
                    }
                }
                
            }
            
            // just cycled through a word.  move the bookmark forward
            // by the length of the word plus a space
            bookmark += word.length + 1
            
        }
        
        // Use textView.attributedText instead of textView.text
        self.attributedText = attrString
    }
    
    private func chopOffNonAlphaNumericCharacters(text:String) -> String {
        let nonAlphaNumericCharacters = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let characterArray = text.componentsSeparatedByCharactersInSet(nonAlphaNumericCharacters)
        return characterArray[0]
    }
}
