Pod::Spec.new do |s|
  s.name        = "DRNet"
  s.version     = "1.0.4"
  s.summary     = "iOS / OS X networking library written in Swift"
  s.homepage    = "https://github.com/darrarski/DRNet.git"
  s.license     = { :type => "MIT" }
  s.authors     = { "Darrarski" => "darrarski@gmail.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.source   = { :git => "https://github.com/darrarski/DRNet.git", :tag => "v1.0.4"}
  s.source_files = "DRNet/**/*.swift"
end