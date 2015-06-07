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
            var testCase = "a\(delimiter)b\(delimiter)c\(delimiter)d"
            println("Splitting '\(testCase)' on `\(delimiter)`")

            var results = testCase.split(delimiter)
            
            XCTAssertEqual(results.count, 4, "\(results)")
            XCTAssert(results[0] == "a"
                && results[1] == "b"
                && results[2] == "c"
                && results[3] == "d",
            "\(results)")
        }
        
        var testCase = "a".split(";")
        XCTAssert(testCase is Array && testCase.count == 1 && testCase[0] == "a", "\(testCase)")
    }
    
    func testStringSub() {
        println("Testing String.gsub")
        var testString = "abcdaA"
        var testCase = testString.gsub("a", "b")
        XCTAssertEqual(testCase, "bbcdbA", "\(testCase)")
        
        println("Testing String.gsub with callback")
        var testCase2 = testString.gsub("a") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase2, "bbcdbA", "\(testCase2)")
        
        println("Testing String.gsubi")
        var testCase3 = testString.gsubi("A", "b")
        XCTAssertEqual(testCase3, "bbcdbb", "\(testCase3)")
        
        println("Testing String.gsubi with callback")
        var testCase4 = testString.gsubi("A") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase4, "bbcdbb", "\(testCase4)")
        
        println("Testing String.sub")
        var testCase5 = testString.sub("a", "b")
        XCTAssertEqual(testCase5, "bbcdaA", "\(testCase5)")
        
        println("Testing String.subi")
        var testCase6 = testString.subi("A", "b")
        XCTAssertEqual(testCase6, "bbcdaA", "\(testCase6)")
        
        println("Testing String.gsub with callback + options")
        var testCase7 = testString.gsub("a", options: "x") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase7, "bbcdbA", "\(testCase7)")
        
        println("Testing String.gsubi with callback + options")
        var testCase8 = testString.gsubi("a", options: "x") { subpattern in
            return "b"
        }
        XCTAssertEqual(testCase8, "bbcdbb", "\(testCase8)")
        
        //TODO: Test all flags
    }
    
    func testStringMatch() {
        var testString = "bbaaaacccddaasssss"
        var testPattern = "(a+)\\w"
        
        println("Testing String Match")
        if let testCase1 = testString.match(testPattern) {
            XCTAssert(testCase1.count == 2
                && testCase1[0] == "aaaac"
                && testCase1[1] == "aaaa",
                "\(testCase1)")
        } else {
            XCTFail("\(testString) doesn't match \(testPattern)")
        }
        
        println("Testing String Scan")
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
        println("Testing Slice")
        var testString = "bbaaaacccddaasssss"
        var testPattern = "(a+)\\w"
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
        var testString = " #aaa# "

        println("Testing Trim")
        var testCase1 = testString.trim()
        XCTAssertEqual(testCase1, "#aaa#", testCase1)

        println("Testing L Trim")
        var testCase2 = testString.ltrim()
        XCTAssertEqual(testCase2, "#aaa# ", testCase2)

        println("Testing R Trim")
        var testCase3 = testString.rtrim()
        XCTAssertEqual(testCase3, " #aaa#", testCase3)

        println("Testing Trim #")
        var testCase4 = testString.trim("#")
        XCTAssertEqual(testCase4, "aaa", testCase4)

        println("Testing L Trim #")
        var testCase5 = testString.ltrim("#")
        XCTAssertEqual(testCase5, "aaa# ", testCase5)
        
        println("Testing R Trim #")
        var testCase6 = testString.rtrim("#")
        XCTAssertEqual(testCase6, " #aaa", testCase6)
    }
    
    func testStringAttributes() {
        var paragraphStyle = NSParagraphStyle()
        paragraphStyle.setValue(CGFloat(17), forKey: "firstLineHeadIndent")
        paragraphStyle.setValue(CGFloat(20), forKey: "headIndent")
        paragraphStyle.setValue(CGFloat(12), forKey: "paragraphSpacing")
        
        var listStyle = NSParagraphStyle()
        listStyle.setValue(CGFloat(20), forKey: "firstLineHeadIndent")
        listStyle.setValue(CGFloat(30), forKey: "headIndent")
        listStyle.setValue(CGFloat(7), forKey: "paragraphSpacing")
        
        var attrs:  [String: [AnyObject]] = [
            "\\*{2}\\s?(.+?)\\s?\\*{2}": [UIFont.boldSystemFontOfSize(14)],
            "\\*\\b(.+?)\\b\\*": [UIFont.italicSystemFontOfSize(14)],
            "> (.+)\\n": [paragraphStyle, UIColor.yellowColor()],
            "^[\\*\\-] (.+)": [listStyle]
        ]
        
        var testString = "** headline **\r\n*italics*\r\n> ext1\r\n> ext3\r\n> ext3\r\n\r\n* bulleted list item\r\n- bulleted list item 2\r\n** headline *with italics* wow **"
        var targetString = "headline\nitalics\next1ext3ext3\nbulleted list item\nbulleted list item 2\nheadline with italics wow"
        
        var attributedTestString = testString.attribute(attrs)
        
        XCTAssertEqual(attributedTestString.string, targetString, attributedTestString.string)

        var testHtmlString = "<p>headline</p>"
        var targetHtmlString = "headline"
        
        var attributedHtmlString = testHtmlString.attributeHtml()
        
        XCTAssertEqual(attributedHtmlString.string, targetHtmlString, attributedHtmlString.string)
    }
    
    func testHtmlDecoding() {
        var testString = "This tutorial has been one of the best I&#8217;ve seen, and one of the most useful for me. I&#8217;m not much of a pattern-follower, plus I like to improvise a little while knitting. This gave me the knowledge necessary to cast on and run with it, and get good results!".decodeHtmlSpecialCharacters()
        
        var targetString = "This tutorial has been one of the best I’ve seen, and one of the most useful for me. I’m not much of a pattern-follower, plus I like to improvise a little while knitting. This gave me the knowledge necessary to cast on and run with it, and get good results!"
        
        XCTAssertEqual(testString, targetString, testString)
    }
    
    func testOperators() {
        var testString = "aabbbccddd"
        var testPattern = "(\\w{2})\\w"
        
        XCTAssert(testString =~ testPattern, "No matches for `\(testPattern)` in '\(testString)'")

        //var testCase1 = testString[testPattern]
        //var testCase2 = testString[testPattern, 1]
        //XCTAssertEqual(testCase1, "aab", testCase1)
        //XCTAssertEqual(testCase2, "ccd", testCase2)
    }
}
