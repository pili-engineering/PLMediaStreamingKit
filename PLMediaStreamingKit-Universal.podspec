#
# Be sure to run `pod lib lint PLCameraStreamingKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PLMediaStreamingKit"
  s.version          = "2.3.4"
  s.summary          = "Pili iOS media streaming framework via RTMP."
  s.homepage         = "https://github.com/pili-engineering/PLMediaStreamingKit"
  s.license          = 'Apache License, Version 2.0'
  s.author           = { "pili" => "pili@qiniu.com" }
  s.source           = { :http => "https://sdk-release.qnsdk.com/PLMediaStreamingKit-v2.3.4-universal.zip"}

  s.platform     = :ios
  s.ios.deployment_target = '8.0'

  s.requires_arc = true

  s.subspec "universal" do |ss1|
    ss1.vendored_frameworks = ['Pod/Library-Universal/PLMediaStreamingKit.framework', 'Pod/Library-Universal/HappyDNS.framework']
  end
 
  s.frameworks = ['UIKit', 'AVFoundation', 'CoreGraphics', 'CFNetwork', 'AudioToolbox', 'CoreMedia', 'VideoToolbox']
  s.libraries = 'z', 'c++', 'icucore', 'sqlite3'
end
