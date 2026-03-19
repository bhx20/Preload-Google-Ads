#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint preload_google_ads.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'preload_google_ads'
  s.version          = '1.0.6'
  s.summary          = 'A high-performance Flutter plugin for preloading Google Mobile Ads.'
  s.description      = <<-DESC
A high-performance Flutter plugin for preloading Google Mobile Ads (AdMob) in the background. Supports immediate display of App Open, Interstitial, Rewarded, Native, and Banner ads.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Google-Mobile-Ads-SDK'
  s.dependency 'google_mobile_ads'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
