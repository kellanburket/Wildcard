//
//  Wildcard.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import UIKit

private let RestrictedRegexCharacters: [Character] = [
    "[", ".", "+", "*", "/", "{", "\\", "(", ")", "|", "$", "^"
]

internal extension NSRange {
    func toStringIndexRange(input: String) -> Range<String.Index> {
        //println("\(location + length), \(input.utf16Count)")
        var startIndex = advance(input.startIndex, location)
        var endIndex = advance(input.startIndex, location + length)
        var range = Range(start: startIndex, end: endIndex)
        //println(input.substringWithRange(range))
        return range
    }
}

private func cleanPatternString(pattern: String) -> String {
    var parsedPattern = ""
    for d in pattern.unicodeScalars {
        if contains(RestrictedRegexCharacters, Character(d)) {
            parsedPattern += "\\\(d)"
        } else {
            parsedPattern.append(d)
        }
    }
    return parsedPattern
}

public extension String {
    
    /**
        Convert a string into an NSDate object. Currently supports both backslashes and hyphens in the following formats:
            - Y-m-d
            - m-d-Y
            - Y-n-j
            - n-j-Y
        
        :return: a date
    */
    public func toDate() -> NSDate? {

        var patterns = [
            "(\\d{4})[-\\/](\\d{1,2})[-\\/](\\d{1,2})": ["year", "month", "day"],
            "(\\d{1,2})[-\\/](\\d{1,2})[-\\/](\\d{4})": ["year", "month", "day"]
        ]
        
        for (pattern, map) in patterns {
            if let matches = self.match(pattern) {
                println("Matches \(matches)")
                if(matches.count == 4) {
                    var dictionary = [String:String]()
                    
                    for (i, item) in enumerate(map) {
                        dictionary[item] = matches[i + 1]
                    }
                    
                    let calendar = NSCalendar.currentCalendar()
                    let comp = NSDateComponents()
                    
                    if let year = dictionary["year"]?.toInt() {
                        comp.year = year
                        if let month = dictionary["month"]?.toInt() {
                            comp.month = month
                            if let day = dictionary["day"]?.toInt() {
                                comp.day = day
                                comp.hour = 0
                                comp.minute = 0
                                comp.second = 0
                                return calendar.dateFromComponents(comp)
                            }
                        }
                    }
                }
            }
        }
        return nil
    }

    /**
        Split a string into an array of strings by slicing at a delimiter
    
        :param: delimiter

        :return: an array of strings if delimiter matches, or an array with the original string as its only component
    */
    public func split(delimiter: String) -> [String] {
        var parsedDelimiter: String = NSRegularExpression.escapedPatternForString(delimiter)
        
        if let matches = self.scan("(.+?)(?:\(parsedDelimiter)|$)") {
            var arr = [String]()
            for match in matches {
                arr.append(match[1])
            }
            
            return arr
        } else {
            return [self]
        }
    }

    /**
        Substitute result of callback function for all occurences of pattern

        :param: pattern a regular expression string to match against
        :param: callback    a callback function to call on pattern match success
        
        :return:    modified string
    */
    public func gsub(pattern: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern)
        return regex.gsub(self, callback: callback)
    }
    
    /**
        Substitute result of callback function for all occurences of pattern
    
        :param: pattern a regular expression string to match against
        :param: options a string containing option flags
            - i:    case-insenstive match
            - x:    ignore #-prefixed comments and whitespace in this pattern
            - s:    `.` matches `\n`
            - m:    `^`, `$` match the beginning and end of lines, respectively (set by default)
            - w:    use unicode word boundaries
            - c:    ignore metacharacters when matching (e.g, `\w`, `\d`, `\s`, etc..)
            - l:    use only `\n` as a line separator
        :param: callback    a callback function to call on pattern match success
        
        :return:    modified string
    */
    public func gsub(pattern: String, options: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern, options)
        return regex.gsub(self, callback: callback)
    }
    
    /**
        Convenience wrapper for gsub with options
    */
    public func gsub(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern, options)
        return regex.gsub(self, replacement)
    }

    /**
        Convenience wrapper for case-insenstive gsub
    */
    public func gsubi(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern,  "\(options)i")
        return regex.gsub(self, replacement)
    }

    /**
        Convenience wrapper for case-insensitive gsub with callback
    */
    public func gsubi(pattern: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern, "i")
        return regex.gsub(self, callback: callback)
    }
    
    /**
        Convenience wrapper for case-insensitive gsub with callback and options
    */
    public func gsubi(pattern: String, options: String, callback: ((String) -> (String))) -> String {
        var regex = RegExp(pattern, "\(options)i")
        return regex.gsub(self, callback: callback)
    }
    
    
    /**
        Conveneience wrapper for first-match-only substitution
    */
    public func sub(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern, options)
        return regex.sub(self, replacement)
    }
    
    /**
        Conveneience wrapper for case-insensitive first-match-only substitution
    */
    public func subi(pattern: String, _ replacement: String, options: String = "") -> String {
        var regex = RegExp(pattern, "\(options)i")
        return regex.sub(self, replacement)
    }
    
    /**
        Scans and matches only the first pattern

        :param: pattern the pattern to search against
        :options:   (not-required) options for matching--see documentation for `gsub`; defaults to ""
    
        :return:    an array of all matches to the first pattern
    */
    public func match(pattern: String, _ options: String = "") -> [String]? {
        return RegExp(pattern, options).match(self)
    }

    /**
        Scans and matches all patterns

        :param: pattern the pattern to search against
        :options:   (not-required) options for matching--see documentation for `gsub`; defaults to ""
    
        :return:    an array of arrays of each matched pattern
    */
    public func scan(pattern: String, _ options: String = "") -> [[String]]? {
        return RegExp(pattern, options).scan(self)
    }

    /**
        Slices out the parts of the string that match the pattern
    
        :param: pattern the pattern to search against
    
        :return:    an array of the slices
    */
    public mutating func slice(pattern: String) -> [[String]]? {
        var matches = self.scan(pattern)
        self = self.gsub(pattern, "")
        return matches
    }

    /**
        Strip white space or aditional specified characters from beginning or end of string
        
        :param: a string of any characters additional characters to strip off beginning/end of string
        
        :return: trimmed string
    */
    public func trim(_ characters: String = "") -> String {
        var parsedCharacters = NSRegularExpression.escapedPatternForString(characters)
        return self.gsub("^[\\s\(parsedCharacters)]+|[\\s\(parsedCharacters)]+$", "")
    }

    /**
        Strip white space or aditional specified characters from end of string
        
        :param: a string of any characters additional characters to strip off end of string
        
        :return: trimmed string
    */
    public func rtrim(_ characters: String = "") -> String {
        var parsedCharacters = NSRegularExpression.escapedPatternForString(characters)
        return self.gsub("[\\s\(parsedCharacters)]+$", "")
    }

    /**
        Strip white space or aditional specified characters from beginning of string
        
        :param: a string of any characters additional characters to strip off beginning of string
        
        :return: trimmed string
    */
    public func ltrim(_ characters: String = "") -> String {
        var parsedCharacters = NSRegularExpression.escapedPatternForString(characters)
        return self.gsub("^[\\s\(parsedCharacters)]+", "")
    }

    /**
        Add attributes to a string where the pattern matches
        
        :param: a dictionary with the pattern as the key and a dictionary of attributes as values. The following keys can be applied to the values dictionary:
    
            - NSFontAttributeName
            - NSForegroundColorAttributeName
            - NSParagraphStyleAttributeName
    
        :return: an attributed string with styles applied
    */
    public func attribute(attributes: [String: [AnyObject]]) -> NSAttributedString {
        var textAttrs = [TextAttribute]()

        for (pattern, attrs) in attributes {
            var map = [NSObject: AnyObject]()
            
            for attr in attrs {
                if attr is UIFont {
                    map[NSFontAttributeName] = attr
                } else if attr is NSParagraphStyle {
                    map[NSParagraphStyleAttributeName] = attr
                } else if attr is UIColor {
                    map[NSForegroundColorAttributeName] = attr
                }
            }
            
            textAttrs.append(TextAttribute(pattern: pattern, attribute: map))
        }
        
        return RegExp(attributes: textAttrs).attribute(self)
    }

    /**
        Converts Html special characters to their ASCII equivalents
    
        :return:    converted string
    */
    public func decodeHtmlSpecialCharacters() -> String {
        var regex = RegExp("&#[a-fA-F\\d]+;")
        
        return regex.gsub(self) { pattern in
            var hex = RegExp("[a-fA-F\\d]+")
            var matches = hex.match(pattern)
            
            if let match = matches?[0] {
                if let sint = match.toInt() {
                    var character = Character(UnicodeScalar(UInt32(sint)))
                    return "\(character)"
                }
            }
            return ""
        }
    }

    /**
        Helper method that parses an Html string and converts it to an attributed string

        :param: map (optional) a map of patterns: text attributes
    
        :return:    an attributed strings without html tags
    */
    public func attributeHtml(map: [String:[AnyObject]] = [String:[AnyObject]]()) -> NSAttributedString {
        
        var str = self.gsub("\\<.*br>", "\n").decodeHtmlSpecialCharacters()
        
        var paragraphStyle = NSParagraphStyle()
        paragraphStyle.setValue(CGFloat(17), forKey: "firstLineHeadIndent")
        paragraphStyle.setValue(CGFloat(20), forKey: "headIndent")
        paragraphStyle.setValue(CGFloat(12), forKey: "paragraphSpacing")
        
        var listStyle = NSParagraphStyle()
        listStyle.setValue(CGFloat(20), forKey: "firstLineHeadIndent")
        listStyle.setValue(CGFloat(30), forKey: "headIndent")
        listStyle.setValue(CGFloat(7), forKey: "paragraphSpacing")
        
        var attributes: [String:[AnyObject]] = [
            "li": [listStyle],
            "(?:b|bold|strong)": [UIFont.boldSystemFontOfSize(12)],
            "(?:i)": [UIFont.italicSystemFontOfSize(12)],
            "a": [UIFont.systemFontOfSize(12)],
            "(?:p|ul|ol|div|section|main)": [paragraphStyle],
            "h\\d+": [UIFont.boldSystemFontOfSize(14)],
        ]
        
        for (k, v) in map {
            attributes[k] = v
        }

        var parsedAttributes = [String:[AnyObject]]()
        
        
        
        for (el, attr) in attributes {
            parsedAttributes["\\<\(el).*?>(.+?)\\<\\/\(el)>"] = attr
        }
        
        return self.attribute(parsedAttributes)
    }
    

    internal func attribute(attributes: [TextAttribute]) -> NSAttributedString {
        return RegExp(attributes: attributes).attribute(self)
    }

    internal func substringWithNSRange(range: NSRange) -> String {
        return substringWithRange(range.toStringIndexRange(self))
    }
    
    internal func substringRanges(pattern: String, _ options: String = "") -> [RegExpMatch]? {
        return RegExp(pattern, options).getSubstringRanges(self)
    }
    
    internal func toMutable() -> NSMutableString {
        var capacity = Swift.count(self.utf16)
        var mutable = NSMutableString(capacity: capacity)
        mutable.appendString(self)
        return mutable
    }
    
    internal func toRange() -> NSRange {
        let capacity = Swift.count(self.utf16)
        return NSMakeRange(0, capacity)
    }

    public subscript(pattern: String) -> [[String]]? {
        get {
            return scan(pattern)
        }
    }
    
    public subscript(pattern: String, replacement: String) -> String {
        get {
            return gsub(pattern, replacement)
        }
    }
}

public extension NSMutableString {
    public func gsub(pattern: String, _ replacement: String) -> NSMutableString {
        var regex = RegExp(pattern)
        return regex.gsub(self, replacement)
    }
    
    internal func substringRanges(pattern: String, _ options: String = "") -> [RegExpMatch]? {
        return RegExp(pattern, options).getSubstringRanges(self as String)
    }
}

public extension NSMutableAttributedString {
    internal func substringRanges(pattern: String, _ options: String = "") -> [RegExpMatch]? {
        return RegExp(pattern, options).getSubstringRanges(self)
    }
}