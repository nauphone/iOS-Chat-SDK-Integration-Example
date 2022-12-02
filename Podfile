platform :ios, '11.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/nauphone/chatpods.git'


post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
    config.build_settings['ENABLE_BITCODE'] = 'NO'
  end
end


target 'iOS Chat SDK Integration Example' do
  use_frameworks!
  
  pod 'ChatSDK', :git => 'https://login:password@nauphone.naumen.ru/repo', :tag => '22.11.2.0'

end
