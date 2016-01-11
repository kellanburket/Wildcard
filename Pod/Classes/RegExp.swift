//
//  RegExp.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import Foundation

/**
    Wrapper class for NSRegularExpression with convenience methods for common string-parsing operations
*/
public class RegExp {

    private var pattern: String = ""
    private var attributes = [TextAttribute]()
    private var replacement: String = ""
    private var options: UInt = 0
    private var mOptions: UInt = 0
    private var regExp: NSRegularExpression?

    /**
        Initialize a new Regular Expression object with a pattern and options. The following flags are permitted:
    
        * i:    case-insenstive match
        * x:    ignore #-prefixed comments and whitespace in this pattern
        * s:    `.` matches `\n`
        * m:    `^`, `$` match the beginning and end of lines, respectively (set by default)
        * w:    use unicode word boundaries
        * c:    ignore metacharacters when matching (e.g, `\w`, `\d`, `\s`, etc..)
        * l:    use only `\n` as a line separator
    
        - parameter pattern: an ICU-style regular expression
        - parameter options: a string containing option flags
    
    */
    public init(_ pattern: String, _ options: String = "") {
        setOptions("\(options)m")
        self.pattern = pattern
    }

    /**
        Convenience initializer for a MutableAttributedString
    */
    public convenience init(_ pattern: NSMutableAttributedString, _ options: String = "") {
        self.init(pattern.mutableString as String)
    }

    internal init(attributes: [TextAttribute], options: String = "") {
        setOptions("\(options)m")
        self.attributes = attributes
    }
    
    /**
        Counts the number of matches in a string
        
        - parameter input:   an input string
    
        - returns:    the number of matches in the input string
    */
    public func count(input: String) -> Int? {
        let capacity = input.utf16.count
        
        if let regExp = doRegExp() {
            return regExp.numberOfMatchesInString(
                input,
                options: NSMatchingOptions(rawValue: mOptions),
                range: NSMakeRange(
                    0,
                    capacity
                )
            )
        }
        
        return nil
    }

    /**
        Looks for the first ICU-style pattern match in the input string
    
        - parameter input:   an input string
        
        - returns:    an array of matches or nil
    */
    public func match(var input: String) -> [String]? {
        input = input.stringByReplacingOccurrencesOfString("\n", withString: "\\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var matches: [String] = [String]()
        
        getFirstMatch(input) { result in

            let numRanges = result.numberOfRanges
            
            for i in 0..<numRanges {
                let range = result.rangeAtIndex(i)
                let match = input.substringWithRange(range.toStringIndexRange(input))
                matches.append(match)
            }
        }
        
        switch matches.count {
            case 0: return nil
            default: return matches
        }
    }

    /**
        Looks for all ICU-style pattern matches in the input string
        
        - parameter input:   an input string
        
        - returns:    an array of an array of matches or nil
    */
    public func scan(var input: String) -> [[String]]? {
        input = input.stringByReplacingOccurrencesOfString("\n", withString: "\\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var matches: [[String]] = [[String]]()
        
        getMatches(input) { result, index in
            
            if matches.count - 1 < index {
                matches.append([String]())
            }
            
            let numRanges = result.numberOfRanges
            
            for i in 0..<numRanges {
                let range = result.rangeAtIndex(i)
                let match = input.substringWithRange(range.toStringIndexRange(input))
                matches[index].append(match)
            }
        }
        
        switch matches.count {
            case 0: return nil
            default: return matches
        }
    }
    
    private func getAllMatches(input: String, reverse: Bool,  onMatch: (NSTextCheckingResult, Int) -> Void) {
        if let regExp = doRegExp() {
            var results = regExp.matchesInString(
                input,
                options: NSMatchingOptions(rawValue: mOptions),
                range: input.toRange()
            )
            
            if reverse {
                results = Array(results.reverse())
            }
                
            for (i, result) in results.enumerate() {
                onMatch(result, i)
            }
        }
    }
    
    private func getFirstMatch(input: String, onMatch: (NSTextCheckingResult) -> Void) {
        if let regExp = doRegExp() {
            
            let range = makeRange(input)
            
            var results = regExp.matchesInString(
                input,
                options: NSMatchingOptions(rawValue: mOptions),
                range: range
            )

            if results.count > 0 {
                onMatch(results[0])
            }
        }
    }
    
    private func getMatches(input: String, onMatch: (NSTextCheckingResult, Int) -> Void) {
        getAllMatches(input, reverse: false, onMatch: onMatch)
    }
    
    private func getReverseMatches(input: String, onMatch: (NSTextCheckingResult, Int) -> Void) {
        getAllMatches(input, reverse: true, onMatch: onMatch)
    }
    
    //Substitution
    internal func gsub(attributed: NSMutableAttributedString, _ replacement: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: gsub(attributed.mutableString, replacement) as String)
    }

    /**
        Substitute all matches in input string with replacement string
        
        - parameter input:   an input string
        - parameter replacement: replacement string (supports back references)
    
        - returns:    the modified input string
    */
    public func gsub(string: String, _ replacement: String) -> String {
        return gsub(string.toMutable(), replacement) as String
    }
    
    internal func gsub(mutable: NSMutableString, _ replacement: String) -> NSMutableString {
        self.replacement = replacement
        if let regExp = doRegExp() {
            regExp.replaceMatchesInString(
                mutable,
                options: NSMatchingOptions(rawValue: mOptions),
                range: NSMakeRange(0, mutable.length),
                withTemplate: self.replacement
            )
        }
        return mutable
    }

    /**
        Substitute all matches in input string with return value of callback function
        
        - parameter input:   an input string
        - parameter callback:    a callback function that takes a match as an argument and returns a modified string (does not support back references)
        
        - returns:    the modified input string
    */
    public func gsub(string: String, callback: ((String) -> (String))) -> String {
        return gsub(string.toMutable(), callback: callback) as String
    }
    
    internal func gsub(mutable: NSMutableString, callback: ((String) -> (String))) -> NSMutableString {
        getReverseMatches(mutable as String) { result, index in
            let numRanges = result.numberOfRanges
            for i in 0..<numRanges {
                let range = result.rangeAtIndex(i)
                let substring = mutable.substringWithRange(range)
                //println("Replacing: \(substring)")
                mutable.replaceCharactersInRange(range, withString: callback(substring))
            }
            
        }
        
        return mutable
    }
    
    /**
        Substitute the first matches in input string with replacement string
        
        - parameter input:   an input string
        - parameter replacement: replacement string (supports back references)
        
        - returns:    the modified input string
    */
    public func sub(string: String, _ replacement: String) -> String {
        let mutable = string.toMutable()
        
        getFirstMatch(string) { result in
            if let regExp = self.regExp {
                
                let substitute = regExp.replacementStringForResult(
                    result,
                    inString: string,
                    offset: 0,
                    template: replacement
                )
                
                mutable.replaceCharactersInRange(
                    result.rangeAtIndex(0),
                    withString: substitute
                )
            }
        }
        
        return mutable as String
    }
    

    /**
        Apply text attribution to an input string
    
        - parameter input:   an input string
        - parameter font:    set the default font
    
        - returns:    A mutable attributed string
    */
    public func attribute(var input: String, font: UIFont? = nil) -> NSMutableAttributedString {
        removeLinebreaks(&input)

        let attributedText = NSMutableAttributedString(string: input)
        
        attributedText.addAttribute(
            NSFontAttributeName,
            value: font ?? UIFont.systemFontOfSize(14),
            range: NSMakeRange(0, attributedText.length)
        )
        
        for attribute in attributes {
            self.pattern = attribute.pattern
            
            getMatches(input) { result, index in
                if result.numberOfRanges >= 2 {
                    attribute.addMatch(input, result.rangeAtIndex(0), result.rangeAtIndex(1))
                }
            }
        }
        
        let matches = TextAttribute.nest(attributes)
        
        for match in matches {
            if let string = attributedText.attributedSubstringFromRange(match.subrange).mutableCopy() as? NSMutableAttributedString {
                
                var replacement = RegExp(pattern).gsub(string, "$1")
                
                match.applyAttributes(&replacement)
                match.formatSubexpressions(&replacement)
                
                attributedText.replaceCharactersInRange(match.fullrange, withAttributedString: replacement)
            }
        }
        
        return attributedText
    }
    
    //Utility functions for finding substring ranges
    private func makeRange(input: String) -> NSRange {
        let capacity = input.utf16.count
        return NSMakeRange(0, capacity)
    }

    internal func getSubstringRanges(input: NSMutableAttributedString) -> [RegExpMatch]? {
        return getSubstringRanges(input.mutableString as String)
    }
    
    internal func getSubstringRanges(input: String) -> [RegExpMatch]? {
        var matches = [RegExpMatch]()
        
        getMatches(input) { result, index in
            let numRanges = result.numberOfRanges
            let matchRange = result.rangeAtIndex(0)
            let match = input.substringWithNSRange(matchRange)
            
            let regExpMatch: MatchTuple = (match, matchRange)
            var regExpSubmatches: [MatchTuple] = [MatchTuple]()
            
            for i in 1..<numRanges {
                let submatchRange = result.rangeAtIndex(i)
                let submatch = input.substringWithNSRange(submatchRange)
                regExpSubmatches.append((submatch, submatchRange))
            }
            
            let nextMatch = RegExpMatch(
                pattern: self.pattern,
                match: regExpMatch,
                submatches: regExpSubmatches
            )
            
            matches.append(nextMatch)
        }
        
        if matches.count > 0 {
            return matches
        }
        
        return nil
    }
    
    ///TODO: Find out what these do and use them or don't
    private func setMatchingOptions(flags: String) -> UInt {
        /*
        NSMatchingOptions.ReportProgress
        NSMatchingOptions.ReportCompletion
        NSMatchingOptions.Anchored
        NSMatchingOptions.WithTransparentBounds
        NSMatchingOptions.WithoutAnchoringBounds
        */
        mOptions = UInt(0)
        return mOptions
    }
    
    private func setOptions(flags: String) -> UInt {
        var options: UInt = 0
        
        for character in flags.characters {
            switch(character) {
            case("i"):
                options |= NSRegularExpressionOptions.CaseInsensitive.rawValue
            case("x"):
                options |= NSRegularExpressionOptions.AllowCommentsAndWhitespace.rawValue
            case("s"):
                options |= NSRegularExpressionOptions.DotMatchesLineSeparators.rawValue
            case("m"):
                options |= NSRegularExpressionOptions.AnchorsMatchLines.rawValue
            case("w"):
                options |= NSRegularExpressionOptions.UseUnicodeWordBoundaries.rawValue
            case("c"):
                options |= NSRegularExpressionOptions.IgnoreMetacharacters.rawValue
            case("l"):
                options |= NSRegularExpressionOptions.UseUnixLineSeparators.rawValue
            default:
                options |= 0
            }
        }
        
        self.options = options
        
        return options;
    }
    
    private func removeLinebreaks(inout input: String) {
        input = input.stringByReplacingOccurrencesOfString("\r\n", withString: "\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    private func doRegExp() -> NSRegularExpression? {
        
        var error: NSError?
        
        do {
            regExp = try NSRegularExpression(
                pattern: pattern,
                options: NSRegularExpressionOptions(rawValue: options)
            )
        } catch let error1 as NSError {
            error = error1
            regExp = nil
        }

        if error != nil {
            print("!!Error: There was an problem matching `\(pattern)`: \(error)")
            return nil
        } else {
            return regExp
        }
    }
}