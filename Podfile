# platform :ios, '17.5'

target 'Application' do
    use_frameworks!
    pod 'SmackSDK', :path => './SmackSDK'
end

post_install do | installer |
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
    end
end
