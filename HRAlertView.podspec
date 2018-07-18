#
#  Be sure to run `pod spec lint HRAlertView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name                      = 'HRAlertView'
    s.version                   = '1.0.1'
    s.summary                   = 'A customer AlertView'
    s.homepage                  = 'https://github.com/luhuaren/HRAlertView'
    s.license                   = { :type => 'TbagLicense', :file => 'LICENSE' }
    s.author                    = { 'tbag' => 'tbag@163.com' }
    s.source                    = { :git => 'https://github.com/luhuaren/HRAlertView.git', :tag => s.version}
    s.frameworks                = 'Foundation', 'UIKit'
    s.exclude_files             = '**/*.md', '**/LICENSE'
    s.source_files              = 'HRAlertView/{HRAlertView.h,HRAlertView.m}'
    
    s.requires_arc              = true
    s.static_framework          = true
    s.ios.deployment_target     = '8.0'
    s.dependency 'Masonry',     '~> 1.1.0'
end
