//
//  TextAttribute.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import Foundation

internal class TextAttribute: NSObject {
    var attribute: [NSObject: AnyObject]
    var pattern: String
    var matches = [RegExpMatch]()
    
    
    internal init(pattern: String, attribute: [NSObject: AnyObject]) {
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