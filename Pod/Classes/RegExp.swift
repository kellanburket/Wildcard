//
//  RegExp.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import Foundation

public class RegExp {

    private var pattern: String = ""
    private var attributes = [TextAttribute]()
    private var replacement: String = ""
    private var options: NSRegularExpressionOptions = NSRegularExpressionOptions.allZeros
    private var mOptions: NSMatchingOptions = NSMatchingOptions.allZeros
    private var regExp: NSRegularExpression?
    
    internal init(attributes: [TextAttribute], options: String = "") {
        setOptions("\(options)m")
        self.attributes = attributes
    }
    
    public init(_ pattern: String, _ options: String = "") {
        setOptions("\(options)m")
        self.pattern = pattern
    }
    
    public convenience init(_ pattern: NSMutableAttributedString, _ options: String = "") {
        self.init(pattern.mutableString as String)
    }

    //Matching
    public func count(input: String) -> Int? {
        var capacity = Swift.count(input.utf16)
        
        if let regExp = doRegExp() {
            return regExp.numberOfMatchesInString(
                input,
                options: mOptions,
                range: NSMakeRange(
                    0,
                    capacity
                )
            )
        }
        
        return nil
    }

    public func match(var input: String) -> [String]? {
        input = input.stringByReplacingOccurrencesOfString("\n", withString: "\\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var matches: [String] = [String]()
        
        getFirstMatch(input) { result in

            var numRanges = result.numberOfRanges
            
            for i in 0..<numRanges {
                var range = result.rangeAtIndex(i)
                var match = input.substringWithRange(range.toStringIndexRange(input))
                matches.append(match)
            }
        }
        
        switch matches.count {
            case 0: return nil
            default: return matches
        }
    }
    
    public func scan(var input: String) -> [[String]]? {
        input = input.stringByReplacingOccurrencesOfString("\n", withString: "\\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var matches: [[String]] = [[String]]()
        
        getMatches(input) { result, index in
            
            if matches.count - 1 < index {
                matches.append([String]())
            }
            
            var numRanges = result.numberOfRanges
            
            for i in 0..<numRanges {
                var range = result.rangeAtIndex(i)
                var match = input.substringWithRange(range.toStringIndexRange(input))
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
            if var results = regExp.matchesInString(input, options: mOptions, range: input.toRange()) as? [NSTextCheckingResult] {
                
                if reverse {
                    results = results.reverse()
                }
                
                for (i, result) in enumerate(results) {
                    onMatch(result, i)
                }
            }
        }
    }
    
    private func getFirstMatch(input: String, onMatch: (NSTextCheckingResult) -> Void) {
        if let regExp = doRegExp() {
            
            let range = makeRange(input)
            
            if var results = regExp.matchesInString(input, options: mOptions, range: range) as? [NSTextCheckingResult] {
                if results.count > 0 {
                    onMatch(results[0])
                }
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
    
    public func gsub(string: String, _ replacement: String) -> String {
        return gsub(string.toMutable(), replacement) as String
    }
    
    internal func gsub(mutable: NSMutableString, _ replacement: String) -> NSMutableString {
        self.replacement = replacement
        if let regExp = doRegExp() {
            regExp.replaceMatchesInString(
                mutable,
                options: mOptions,
                range: NSMakeRange(0, mutable.length),
                withTemplate: self.replacement
            )
        }
        return mutable
    }
    
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
    
    public func sub(string: String, _ replacement: String) -> String {
        var mutable = string.toMutable()
        
        getFirstMatch(string) { result in
            if let regExp = self.regExp {
                let numRanges = result.numberOfRanges
                
                var substitute = regExp.replacementStringForResult(
                    result,
                    inString: string,
                    offset: 0,
                    template: replacement
                )
                
                let range = result.rangeAtIndex(0)
                let substring = mutable.substringWithRange(range)
                mutable.replaceCharactersInRange(range, withString: substitute)
            }
        }
        
        return mutable as String
    }
    
    //Attribution
    public func attribute(var input: String) -> NSMutableAttributedString {
        removeLinebreaks(&input)
        var capacity = Swift.count(input.utf16)
        
        var attributedText = NSMutableAttributedString(string: input)
        
        for attribute in attributes {
            self.pattern = attribute.pattern
            
            getMatches(input) { result, index in
                if result.numberOfRanges >= 2 {
                    attribute.addMatch(input, result.rangeAtIndex(0), result.rangeAtIndex(1))
                }
            }
        }
        
        var matches = TextAttribute.nest(attributes)
        
        for match in matches {
            if var string = attributedText.attributedSubstringFromRange(match.subrange).mutableCopy() as? NSMutableAttributedString {
                
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
        var capacity = Swift.count(input.utf16)
        return NSMakeRange(0, capacity)
    }

    internal func getSubstringRanges(input: NSMutableAttributedString) -> [RegExpMatch]? {
        return getSubstringRanges(input.mutableString as String)
    }
    
    internal func getSubstringRanges(input: String) -> [RegExpMatch]? {
        var capacity = Swift.count(input.utf16)
        var matches = [RegExpMatch]()
        
        getMatches(input) { result, index in
            var numRanges = result.numberOfRanges
            var matchRange = result.rangeAtIndex(0)
            var match = input.substringWithNSRange(matchRange)
            
            var regExpMatch: MatchTuple = (match, matchRange)
            var regExpSubmatches: [MatchTuple] = [MatchTuple]()
            
            for i in 1..<numRanges {
                var submatchRange = result.rangeAtIndex(i)
                var submatch = input.substringWithNSRange(submatchRange)
                regExpSubmatches.append((submatch, submatchRange))
            }
            
            var nextMatch = RegExpMatch(
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
    
    //TODO: Find out what these do and use them or don't
    private func setMatchingOptions(flags: String) -> NSMatchingOptions {
        var options = NSMatchingOptions.allZeros
        /*
        NSMatchingOptions.ReportProgress
        NSMatchingOptions.ReportCompletion
        NSMatchingOptions.Anchored
        NSMatchingOptions.WithTransparentBounds
        NSMatchingOptions.WithoutAnchoringBounds
        */
        self.mOptions = options
        return options;
    }
    
    private func setOptions(flags: String) -> NSRegularExpressionOptions {
        var options: NSRegularExpressionOptions = NSRegularExpressionOptions.allZeros
        
        for character in flags {
            switch(character) {
            case("i"):
                options |= NSRegularExpressionOptions.CaseInsensitive
            case("x"):
                options |= NSRegularExpressionOptions.AllowCommentsAndWhitespace
            case("s"):
                options |= NSRegularExpressionOptions.DotMatchesLineSeparators
            case("m"):
                options |= NSRegularExpressionOptions.AnchorsMatchLines
            case("w"):
                options |= NSRegularExpressionOptions.UseUnicodeWordBoundaries
            case("c"):
                options |= NSRegularExpressionOptions.IgnoreMetacharacters
            case("l"):
                options |= NSRegularExpressionOptions.UseUnixLineSeparators
            default:
                options |= NSRegularExpressionOptions.allZeros
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
        
        regExp = NSRegularExpression(
            pattern: pattern,
            options: options,
            error: &error
        )

        if let e = error {
            println("!!Error: There was an problem matching `\(pattern)`: \(error)")
            return nil
        } else {
            return regExp
        }
    }
}