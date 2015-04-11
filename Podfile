platform :ios, '8.0'

inhibit_all_warnings!
use_frameworks!

link_with 'Ketch', 'KetchTests'

pod 'ReactiveCocoa', '~> 2.4' # Update to 3.0 when ready

pod 'SugarRecord/CoreData', :git => 'https://github.com/tonyxiao/SugarRecord'
pod 'Meteor', :git => 'https://github.com/tonyxiao/meteor-ios', :branch => 'dev'
pod 'SwiftyUserDefaults', '~> 1.0'

pod 'SwipeView', '~> 1.3'
pod 'JSQMessagesViewController', '~> 6.1'
pod 'SDWebImage', '~> 3.7'
pod 'PKHUD', '~> 2.0'

pod 'Cartography', '~> 0.3'
pod 'UICollectionViewLeftAlignedLayout', '~> 0.0.3'

#pod 'Spring', '~> 1.0'
#pod 'pop', '~> 1.0'
pod 'RBBAnimation', '~> 0.3.0'
pod 'Shimmer', '~> 1.0'

pod 'EDColor', '~> 0.4'
pod 'DateTools', '~> 1.5'
pod 'TCMobileProvision', :git => 'https://github.com/tonyxiao/TCMobileProvision.git'

# 3rd Party Service SDKs
pod 'Facebook-iOS-SDK', '~> 3.22'
pod 'CrashlyticsFramework', '~> 2.2'
pod 'BugfenderSDK', :git => 'https://github.com/bugfender/BugfenderSDK-iOS.git', :tag => '0.3.2'

# Debug only

pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
pod 'NSLogger', '~> 1.5', :configuration => ['Debug']

# Hacks
post_install do |installer|
    installer.project.targets.each do |target|
        # DateTools Hack https://github.com/MatthewYork/DateTools/issues/56 Disable localization in exchange for no crash
        if target.name == 'Pods-DateTools'
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'DateToolsLocalizedStrings(key)=key'
            end
        end
    end
end

# Might be useful one day
#pod 'SwiftyJSON', '~> 2.1'
#pod 'ExSwift', '~> 0.1.9'
