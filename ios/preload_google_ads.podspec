Pod::Spec.new do |s|
  s.name             = 'preload_google_ads'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for preloading Google Mobile Ads.'
  s.description      = <<-DESC
A Flutter plugin for preloading Google Mobile Ads to improve ad loading performance.
                       DESC
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'Google-Mobile-Ads-SDK'
  s.platform = :ios, '13.0'

  # Pure Swift configuration - no module issues
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'NO',
    'SWIFT_EMIT_MODULE_INTERFACE' => 'NO'
  }
  s.swift_version = '5.0'
end