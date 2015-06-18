platform :ios, '8.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

target :Core do
    link_with 'Core'
    # Foundation
    pod 'ReactiveCocoa', '~> 2.4' # Update to 3.0 when ready
    pod 'SwiftTryCatch', '~> 0.0.1'
    pod 'NSLogger', '~> 1.5', :configuration => ['Debug']

    # Data
    pod 'SugarRecord/CoreData', :git => 'https://github.com/tonyxiao/SugarRecord', :branch => 'develop'
    pod 'Meteor', :git => 'https://github.com/tonyxiao/meteor-ios', :branch => 'dev'
    pod 'SwiftyUserDefaults', '~> 1.1'

    # Networking
    pod 'Alamofire', '~> 1.2'

    # UI
    pod 'Cartography', '~> 0.5'
    pod 'EDColor', '~> 1.0'

    # Utils
    pod 'SimpleKeychain', '~> 0.4'
    pod 'TCMobileProvision', :git => 'https://github.com/tonyxiao/TCMobileProvision.git'

    target :CoreTests do
        link_with 'CoreTests'
        pod 'Quick', '~> 0.3.0' # TODO: Upgrade after swift 2.0
        pod 'Nimble', '~> 0.4.0' # TODO: Upgrade after swift 2.0
    end

    target :Taylr do
        link_with 'Taylr'

        pod 'SwipeView', '~> 1.3'
        pod 'SDWebImage', '~> 3.7'
        pod 'PKHUD', :git => 'https://github.com/tonyxiao/PKHUD' # Fork is needed to work around xcasset compilation issue inside pod
        pod 'XLForm', '~> 2.2'

        pod 'UICollectionViewLeftAlignedLayout', '~> 1.0'

        #pod 'Spring', '~> 1.0'
        #pod 'pop', '~> 1.0'
        pod 'RBBAnimation', '~> 0.4.0'


        pod 'DateTools', '~> 1.5'
        pod 'FormatterKit/TimeIntervalFormatter', '~> 1.8'

        pod 'INTULocationManager', '~> 3.0'

        # 3rd Party Service SDKs
        pod 'Facebook-iOS-SDK', '3.22.0' # TODO: Upgrade me when ready
        #pod 'CrashlyticsFramework', '~> 2.2'
        #pod 'BugfenderSDK', :git => 'https://github.com/bugfender/BugfenderSDK-iOS.git', :tag => '0.3.2'
        pod 'AnalyticsSwift', '~> 0.1.0'
        pod 'Heap', '~> 2.1'
#        pod 'Analytics/Mixpanel', :git => 'https://github.com/tonyxiao/analytics-ios.git'
#        pod 'Analytics/Amplitude', :git => 'https://github.com/tonyxiao/analytics-ios.git'
        #pod 'Analytics/Kahuna', :git => 'https://github.com/tonyxiao/analytics-ios.git'

        # Debug only

        pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
    end

    target :TestApp do
        link_with 'TestApp'
        pod 'SCRecorder', '~> 2.4'
        pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
    end
end

# Might be useful one day
#pod 'SwiftyJSON', '~> 2.1'
#pod 'ExSwift', '~> 0.1.9'
