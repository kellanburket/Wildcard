#
# Be sure to run `pod lib lint Wildcard.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Wildcard"
  s.version          = "1.0.6"
  s.summary          = "A RegEx framework for Swift"
  s.description      = <<-DESC
        Wildcard is a Swift RegEx(Regular Expressions) framework. It includes common utility methods for parsing and manipulating strings based on Ruby, Perl, and PHP's core string libraries as well as a Perl-style matching operator `string =~ pattern`.

        Currently, advanced text-attribution methods for parsing/styling HTML and custom mark-up languages are in the works and can be used at your own caution.
                        DESC
  s.homepage         = "https://github.com/kellanburket/Wildcard"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Kellan Cummings" => "kellan.burket@gmail.com" }
  s.source           = { :git => "https://github.com/kellanburket/Wildcard.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.3'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Wildcard' => ['Pod/Assets/*.png']
  }
end
