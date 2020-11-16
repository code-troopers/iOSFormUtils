#
# Be sure to run `pod lib lint iOSFormUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "iOSFormUtils"
  s.version          = "0.5.0"
  s.summary          = "iOSFormUtils helps you developping validated forms in iOS apps."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOSFormUtils helps you developping validated forms in iOS apps. You could use it with Email or NotBlank formats.
                       DESC

  s.homepage         = "https://github.com/leloupnicolas/iOSFormUtils"
  s.license          = 'MIT'
  s.author           = { "leloupnicolas" => "colasleloup.nl@gmail.com" }
  s.source           = { :git => "https://github.com/leloupnicolas/iOSFormUtils.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/leloupnicolas'

  s.ios.deployment_target = '8.0'

  s.source_files = 'iOSFormUtils'
 
  s.dependency 'SBPickerSelector', '~> 2.0.6'
  s.dependency 'UIKitExtensions', '~> 0.3.0'
end
