//
//  LinkAttribute.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import Foundation

/**
    Use this class to apply links to segments of attributed text.
*/
public class LinkAttribute: TextAttribute {
    private var links: [String]?
    /**
        Initialize a LinkAttribute with a pattern and links. Given a string:
            
                var str = "[Link1] blah blah blah [Link2]"
    
        Do the following:
    
                LinkAttribute("\\[(.+?)\\]", ["http://link1.com", "http://link2.com"])
    
        Output:
    
                Link 1 blah blah blah Link2
        
        - parameter pattern: pattern to link; include a subpattern--this is the portion of the link that will be visible; the total number of matches should equal the total number of links passed into the `links` argument
        - parameter links:   an array of links to apply to the matched text segment; link index 0 should match the first pattern match and so on and so forth
        - parameter attribute:   any additional text attributes to be applied to link text
    */
    public init(pattern: String, links: [String], attribute: [NSObject: AnyObject]) {
        self.links = links
        super.init(pattern: pattern, attribute: attribute)
    }
    
    override internal func getAttributes() -> [NSObject: AnyObject]? {
        if links != nil && links?.count > 0 {
            if let link = links?.removeAtIndex(0) {
                var attributeToReturn = attribute
                attributeToReturn[NSLinkAttributeName] = link
                return attributeToReturn
            }
        }
        
        return nil
    }
}
