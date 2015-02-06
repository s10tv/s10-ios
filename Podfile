platform :ios, '8.0'

inhibit_all_warnings!

pod 'Facebook-iOS-SDK', '~> 3.22'
pod 'GPUImage', '~> 0.1.6'
pod 'SwipeView', '~> 1.3'
pod 'Snap', '~> 0.0.4'
pod 'SDWebImage', '~> 3.7'
pod 'SwiftyJSON', '~> 2.1'
pod 'Meteor', '~> 0.1'
pod 'MagicalRecord', '~> 2.2' # Shorthand not supported in Swift
pod 'Alamofire', '~> 1.1'
pod 'DateTools', '~> 1.5'
#pod 'ExSwift', '~> 0.1.9'

# Update these to latest when ready
pod 'ReactiveCocoa', '~> 2.4'

# pod 'SugarRecord/CoreData', :git => 'https://github.com/SugarRecord/SugarRecord.git'

# Debug only

pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
pod 'NSLogger', '~> 1.5', :configuration => ['Debug']

# Hacks
post_install do |installer|
    installer.project.targets.each do |target|
        # Disable logging for overly eager library
        if target.name == 'Pods-MagicalRecord'
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'MR_ENABLE_ACTIVE_RECORD_LOGGING=0'
            end
        end
        # DateTools Hack https://github.com/MatthewYork/DateTools/issues/56 Disable localization in exchange for no crash
        if target.name == 'Pods-DateTools'
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DateToolsLocalizedStrings(key)=key'
            end
        end
    end
end
