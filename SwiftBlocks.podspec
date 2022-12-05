Pod::Spec.new do |s|
  s.name             = 'SwiftBlocks'
  s.version          = '0.0.1'
  s.summary          = 'A library for creating user interfaces using reusable components.'
  s.homepage         = 'https://github.com/billp/Blocks.git'
  s.license          = 'MIT'
  s.authors          = { 'Vassilis Panagiotopoulos' => 'billp.dev@gmail.com' }
  s.source           = { :git => 'https://github.com/billp/Blocks.git', :tag => s.version }
  s.documentation_url = 'https://github.com/billp/Blocks'

  s.ios.deployment_target = '13.0'

  s.source_files = 'Source/**/*.swift'

  s.swift_versions = ['5.3']
end
