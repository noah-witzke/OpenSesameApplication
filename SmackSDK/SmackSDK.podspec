Pod::Spec.new do |spec|
  spec.name             = 'SmackSDK'
  spec.version          = '1.4.0'
  spec.summary          = 'TBD'
  spec.swift_version    = '5.0'
  spec.description      = <<-DESC
'© 2021 Infineon Technologies AG. All rights reserved.'
                       DESC
  spec.homepage         = 'https://www.infineon.com'
  spec.license          = { :type => 'TBD', :file => 'LICENSE' }
  spec.author           = { 'x-root Software GmbH' => 'mobile@x-root.de' }
  # For local installation the root folder is the source
  spec.source           = { :http => 'https://www.infineon.com' }
  spec.ios.deployment_target = '13.0'
  spec.vendored_frameworks = "SmackSDK.xcframework"
  spec.dependency 'SwiftLint', '~> 0.51.0'
  spec.dependency 'Resolver', '~> 1.5.0'
  spec.dependency 'CryptoSwift', '~> 1.7.0'
end
