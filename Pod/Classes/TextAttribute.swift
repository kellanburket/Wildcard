//
//  TextAttribute.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import Foundation

/**
    Wrapper class for Text Attributes
*/
public class TextAttribute: NSObject {
    internal var attribute: [NSObject: AnyObject]
    internal var pattern: String
    internal var matches = [RegExpMatch]()
    
    /**
        Initialize a TextAttribute with a pattern and links
        
        :param: pattern pattern to match against
        :param: a dictionary of attributes
    */
    public init(pattern: String, attribute: [NSObject: AnyObject]) {
        self.attribute = attribute
        self.pattern = pattern
    }
    
    internal func addMatch(input: String, _ full: NSRange, _ sub: NSRange) {
        var match = RegExpMatch(
            pattern: pattern,
            match: (input.substringWithNSRange(full), full),
            submatches: [(input.substringWithNSRange(sub), sub)]
        )
        
        match.attributes = [self]
        
        matches.append(match)
    }
    
    internal func getAttributes()  -> [NSObject: AnyObject]? {
        return attribute
    }
    
    internal class func nest(attributes: [TextAttribute]) -> [RegExpMatch] {
        var sets = [RegExpMatch]()
        
        for attr in attributes {
            for match in attr.matches {
                sets.append(match)
            }
        }
        
        RegExpMatch.nest(&sets)
        
        return sets
    }
}