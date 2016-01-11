import UIKit
import XCTest
import Wildcard

class Tests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringToDate() {
        XCTAssertNotNil("2015/01/06".toDate(), "Y/m/d")
        XCTAssertNotNil("01/07/2014".toDate(), "m/d/Y")
        XCTAssertNotNil("2015-01-06".toDate(), "Y-m-d")
        XCTAssertNotNil("01-07-2014".toDate(), "m-d-Y")
        XCTAssertNotNil("2015-1-6".toDate(), "Y-n-j")
        XCTAssertNotNil("1-7-2014".toDate(), "n-j-Y")
    }

    func testStringSplit() {
        for delimiter in [";", ",", "[", ".", "+", "*", "/", "{", "\\", "(", ")", "|", "$", "^"] {
            let testCase = "a\(delimiter)b\(delimiter)c\(delimiter)d"
            print("Splitting '\(testCase)' on `\(delimiter)`")

            var results = testCase.split(delimiter)
            
            XCTAssertEqual(results.count, 4, "\(results)")
            XCTAssert(results[0] == "a"
                && results[1] == "b"
                && results[2] == "c"
                && results[3] == "d",
            "\(results)")
        }
        
        var testCase = "a".split(";")
        XCTAssert(testCase.count == 1 && testCase[0] == "a", "\(testCase)")
    }

    func testStringFormatting() {
        var testString = "Hello World"

        var testCase = testString.toSnakecase()
        XCTAssertEqual(testCase, "hello_world", "\(testCase)")
    
        testCase = testString.toCamelcase()
        XCTAssertEqual(testCase, "HelloWorld", "\(testCase)")

        testString = testCase
        testCase = testString.decapitalize()
        XCTAssertEqual(testCase, "helloWorld", "\(testCase)")

        testString = testCase
        testCase = testString.capitalize()
        XCTAssertEqual(testCase, "HelloWorld", "\(testCase)")
    }
    
    func testStringPlurals() {
        let testStrings = [
            "world": "worlds",
            "grass": "grasses",
            "fieldmouse": "fieldmice",
            "radix": "radices",
            "woman": "women",
            "child": "children",
            "buy": "buys",
            "pony": "ponies",
            "goose": "geese",
            "stand-by": "stand-bys",
            "di": "dice",
            "slice": "slices"
        ]

        for (testString, targetString) in testStrings {
            var testCase = testString.pluralize()
            XCTAssertEqual(testCase, targetString, "\(testCase)")
            
            let test = targetString
            let target = testString
 
            testCase = test.singularize()
            XCTAssertEqual(testCase, target, "\(testCase)")
        }
    }
    
    func testStringSub() {
        print("Testing String.gsub")
        let testString = "abcdaA"
        let testCase = testString.gsub("a", "b")
        XCTAssertEqual(testCase, "bbcdbA", "\(testCase)")
        
        print("Testing String.gsub with callback")
        let testCase2 = testString.gsub("a") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase2, "bbcdbA", "\(testCase2)")
        
        print("Testing String.gsubi")
        let testCase3 = testString.gsubi("A", "b")
        XCTAssertEqual(testCase3, "bbcdbb", "\(testCase3)")
        
        print("Testing String.gsubi with callback")
        let testCase4 = testString.gsubi("A") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase4, "bbcdbb", "\(testCase4)")
        
        print("Testing String.sub")
        let testCase5 = testString.sub("a", "b")
        XCTAssertEqual(testCase5, "bbcdaA", "\(testCase5)")
        
        print("Testing String.subi")
        let testCase6 = testString.subi("A", "b")
        XCTAssertEqual(testCase6, "bbcdaA", "\(testCase6)")
        
        print("Testing String.gsub with callback + options")
        let testCase7 = testString.gsub("a", options: "x") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase7, "bbcdbA", "\(testCase7)")
        
        print("Testing String.gsubi with callback + options")
        let testCase8 = testString.gsubi("a", options: "x") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase8, "bbcdbb", "\(testCase8)")
        
        //TODO: Test all flags
    }
    
    func testStringMatch() {
        let testString = "bbaaaacccddaasssss"
        let testPattern = "(a+)\\w"
        
        print("Testing String Match")
        if let testCase1 = testString.match(testPattern) {
            XCTAssert(testCase1.count == 2
                && testCase1[0] == "aaaac"
                && testCase1[1] == "aaaa",
                "\(testCase1)")
        } else {
            XCTFail("\(testString) doesn't match \(testPattern)")
        }
        
        print("Testing String Scan")
        if let testCase2 = testString.scan(testPattern) {
            XCTAssert(testCase2.count == 2
                && testCase2[0].count == 2
                && testCase2[0][0] == "aaaac"
                && testCase2[0][1] == "aaaa"
                && testCase2[1].count == 2
                && testCase2[1][0] == "aas"
                && testCase2[1][1] == "aa",
                "\(testCase2)")
        } else {
            XCTFail("\(testString) doesn't match \(testPattern)")
        }
    }
    
    func testStringSlice() {
        print("Testing Slice")
        var testString = "bbaaaacccddaasssss"
        let testPattern = "(a+)\\w"
        if let testCase = testString.slice(testPattern) {
            
            XCTAssert(testString == "bbccddssss"
                && testCase.count == 2
                && testCase[0].count == 2
                && testCase[0][0] == "aaaac"
                && testCase[0][1] == "aaaa"
                && testCase[1].count == 2
                && testCase[1][0] == "aas"
                && testCase[1][1] == "aa",
            "\(testCase)")
        } else {
            XCTFail("\(testString) doesn't match \(testPattern)")
        }
    }
    
    func testStringTrim() {
        let testString = " #aaa# "

        print("Testing Trim")
        let testCase1 = testString.trim()
        XCTAssertEqual(testCase1, "#aaa#", testCase1)

        print("Testing L Trim")
        let testCase2 = testString.ltrim()
        XCTAssertEqual(testCase2, "#aaa# ", testCase2)

        print("Testing R Trim")
        let testCase3 = testString.rtrim()
        XCTAssertEqual(testCase3, " #aaa#", testCase3)

        print("Testing Trim #")
        let testCase4 = testString.trim("#")
        XCTAssertEqual(testCase4, "aaa", testCase4)

        print("Testing L Trim #")
        let testCase5 = testString.ltrim("#")
        XCTAssertEqual(testCase5, "aaa# ", testCase5)
        
        print("Testing R Trim #")
        let testCase6 = testString.rtrim("#")
        XCTAssertEqual(testCase6, " #aaa", testCase6)
    }
    
    func testStringAttributes() {
        let paragraphStyle = NSParagraphStyle()
        paragraphStyle.setValue(CGFloat(17), forKey: "firstLineHeadIndent")
        paragraphStyle.setValue(CGFloat(20), forKey: "headIndent")
        paragraphStyle.setValue(CGFloat(12), forKey: "paragraphSpacing")
        
        let listStyle = NSParagraphStyle()
        listStyle.setValue(CGFloat(20), forKey: "firstLineHeadIndent")
        listStyle.setValue(CGFloat(30), forKey: "headIndent")
        listStyle.setValue(CGFloat(7), forKey: "paragraphSpacing")
        
        let attrs:  [String: [AnyObject]] = [
            "\\*{2}\\s?(.+?)\\s?\\*{2}": [UIFont.boldSystemFontOfSize(14)],
            "\\*\\b(.+?)\\b\\*": [UIFont.italicSystemFontOfSize(14)],
            "> (.+)\\n": [paragraphStyle, UIColor.yellowColor()],
            "^[\\*\\-] (.+)": [listStyle]
        ]
        
        let testString = "** headline **\r\n*italics*\r\n> ext1\r\n> ext3\r\n> ext3\r\n* bulleted list item\r\n- bulleted list item 2\r\n** headline *with italics* wow **"
        let targetString = "headline\nitalics\next1ext3ext3bulleted list item\nbulleted list item 2\nheadline with italics wow"
        
        let attributedTestString = testString.attribute(attrs)
        
        XCTAssertEqual(attributedTestString.string, targetString, attributedTestString.string)

        let testHtmlString = "<p>headline</p>"
        let targetHtmlString = "headline"
        
        let attributedHtmlString = testHtmlString.attributeHtml()
        
        XCTAssertEqual(attributedHtmlString.string, targetHtmlString, attributedHtmlString.string)
    }
    
    func testHtmlDecoding() {
        let testString = "This tutorial has been one of the best I&#8217;ve seen, and one of the most useful for me. I&#8217;m not much of a pattern-follower, plus I like to improvise a little while knitting. This gave me the knowledge necessary to cast on and run with it, and get good results!".decodeHtmlSpecialCharacters()
        
        let targetString = "This tutorial has been one of the best I’ve seen, and one of the most useful for me. I’m not much of a pattern-follower, plus I like to improvise a little while knitting. This gave me the knowledge necessary to cast on and run with it, and get good results!"
        
        XCTAssertEqual(testString, targetString, testString)
    }
    
    func testOperators() {
        let testString = "aabbbccddd"
        let testPattern = "(\\w{2})\\w"
        
        XCTAssert(testString =~ testPattern, "No matches for `\(testPattern)` in '\(testString)'")
    }
}
