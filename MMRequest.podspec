Pod::Spec.new do |s|
  s.name             = 'MMRequest'
  s.version          = '0.1.3'
  s.summary          = 'MMRequest'
  s.homepage         = 'https://github.com/HoneyLuka/MMRequest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luka' => 'luka@honeyluka.com' }
  s.source           = { :git => 'https://github.com/HoneyLuka/MMRequest.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/rainfyou'
  s.ios.deployment_target = '8.0'
  s.public_header_files = 'MMRequest/Classes/*.{h}'
  s.source_files = 'MMRequest/Classes/*.{h,m}'
  s.dependency 'AFNetworking'
  s.dependency 'YYModel'
  s.dependency 'PromiseKit', '~> 1.7'
end
