//
//  RegExpMatch.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import Foundation

internal typealias MatchTuple = (string: String, range: NSRange)

internal func ==(right: RegExpMatch, left: RegExpMatch) -> Bool {
    return right.match.range.location == left.match.range.location
        && right.match.range.length == left.match.range.length
}

internal class RegExpMatch: Equatable {
    var pattern: String
    var match: MatchTuple
    var submatches: [MatchTuple]
    var attributes = [TextAttribute]()
    var subexpressions = [RegExpMatch]()
    
    internal init(pattern: String, match: MatchTuple, submatches: [MatchTuple]) {
        self.pattern = pattern
        self.submatches = submatches
        self.match = match
    }
    
    internal var subrange: NSRange {
        get {
            return submatches[0].range
        }
        set(range) {
            submatches[0].range = range
        }
    }
    
    internal var substring: String {
        return submatches[0].string
    }
    
    internal var fullrange: NSRange {
        get {
            return match.range
        }
        
        set(range) {
            match.range = range
        }
    }
    
    internal var fullstring: String {
        return match.string
    }
    
    internal func addSubexpression(sub: RegExpMatch) {
        
        //println("\(sub.fullrange), \(sub.subrange): \(fullrange)")
        sub.fullrange = NSRange(
            location: sub.fullrange.location - fullrange.location,
            length: sub.fullrange.length
        )
        
        sub.subrange = NSRange(
            location: sub.subrange.location - fullrange.location,
            length: sub.subrange.length
        )
        
        for a in attributes {
            sub.attributes.append(a)
        }
        
        subexpressions.append(sub)
    }
    
    internal func applyAttributes(inout string: NSMutableAttributedString) {
        var finalAttributes = [String: AnyObject]()
        
        for attribute in attributes {
            if let attrs = attribute.getAttributes() {
                for (key, value) in attrs {
                    if let attribute_key = key as? String {
                        finalAttributes[attribute_key] = value
                    }
                }
            }
        }
        
        let replacementRange = NSRange(location: 0, length: string.length)

        string.setAttributes(finalAttributes, range: replacementRange)
    }
    
    internal func formatSubexpressions(inout replacement: NSMutableAttributedString) {
        if subexpressions.count > 0 {
            for sub in subexpressions {
                //println("\(replacement.mutableString): \(sub.pattern)")
                if let matches = RegExp(sub.pattern).getSubstringRanges(replacement) {
                    
                    for match in matches {
                        var substring = NSMutableAttributedString(
                            string: match.substring
                        )
                        
                        sub.applyAttributes(&substring)
                        
                        replacement.replaceCharactersInRange(
                            match.fullrange,
                            withAttributedString: substring
                        )
                    }
                }
            }
        }
    }
    
    internal class func nest(inout sets: [RegExpMatch]) {
        for setA in sets {
            for setB in sets {
                if setA != setB {
                    let intersection = NSIntersectionRange(setA.fullrange, setB.fullrange)
                    if intersection.location > 0 && intersection.length > 0 {

                        if setA.fullrange.location <= setB.fullrange.location {
                            if let index = sets.indexOf(setB) {
                                sets.removeAtIndex(index)
                                setA.addSubexpression(setB)
                            }
                        } else {
                            if let index = sets.indexOf(setA) {
                                sets.removeAtIndex(index)
                                setB.addSubexpression(setA)
                            }
                        }
                    }
                }
            }
            
            if setA.subexpressions.count > 1 {
                RegExpMatch.nest(&setA.subexpressions)
            }
        }
        
        sets.sortInPlace {
            $0.fullrange.location > $1.fullrange.location
        }
    }
}