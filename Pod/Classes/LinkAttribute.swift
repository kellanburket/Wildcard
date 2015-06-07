//
//  LinkAttribute.swift
//  Wildcard
//
//  Created by Kellan Cummings on 6/6/15.
//  Copyright (c) 2015 Kellan Cummings. All rights reserved.
//

import Foundation

internal class LinkAttribute: TextAttribute {
    private var links: [String]?
    
    internal init(pattern: String, var links: [String]?) {
        self.links = links
        super.init(pattern: pattern, attribute: [NSObject: AnyObject]())
    }
    
    override internal func getAttributes() -> [NSObject: AnyObject]? {
        if links != nil && links?.count > 0 {
            if let link = links?.removeAtIndex(0) {
                return [NSLinkAttributeName: link]
            }
        }
        
        return nil
    }
}
