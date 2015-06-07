# Wildcard

[![CI Status](http://img.shields.io/travis/Kellan Cummings/Wildcard.svg?style=flat)](https://travis-ci.org/Kellan Cummings/Wildcard)
[![Version](https://img.shields.io/cocoapods/v/Wildcard.svg?style=flat)](http://cocoapods.org/pods/Wildcard)
[![License](https://img.shields.io/cocoapods/l/Wildcard.svg?style=flat)](http://cocoapods.org/pods/Wildcard)
[![Platform](https://img.shields.io/cocoapods/p/Wildcard.svg?style=flat)](http://cocoapods.org/pods/Wildcard)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Wildcard is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Wildcard"
```

## Author

Kellan Cummings, kellan.cummings@gmail.com

## License

Wildcard is available under the MIT license. See the LICENSE file for more info.

## About

Wildcard is a Swift RegExp(Regular Expressions) framework. It includes common utility methods for parsing and manipulating strings based on Ruby, Perl, and PHP's core string libraries:

    - `gsub`, `gsubi`, `sub`, `subi`
    - `match`, `scan`
    - `slice`
    - `split`
    - `trim`, `ltrim`, `rtrim`
    - `toDate`
    - `decodeHtmlSpecialChars`

Currently, advanced text-attribution methods for parsing/styling HTML and custom mark-up languages are in the works and can be used (at your own caution) with `attribute` and `attributeHTML`.