Pod::Spec.new do |s|
  s.name         = "TLLayoutTransitioning"
  s.version      = "0.0.1"
  s.summary      = "TODO"
  s.description  = <<-DESC
					TODO
                    DESC
  s.license      = { :type => "MIT" }
  s.author       = { "wtmoose" => "wtm@tractablelabs.com" }
  s.source       = { :git => "https://github.com/wtmoose/TLLayoutTransitioning.git", :tag => '0.0.1' }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source_files = 'TLLayoutTransitioning/**/*.{h,m}'
  s.frameworks = 'UIKit', 'QuartzCore', 'Foundation'
  s.requires_arc = true
end
