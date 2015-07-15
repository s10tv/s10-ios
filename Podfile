platform :ios, '8.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

target :Core do
    link_with 'Core'
    # Foundation
    pod 'BrightFutures', '~> 2.0'
    pod 'ReactiveCocoa', '3.0-beta.9'
    pod 'Bond', :git => 'https://github.com/tonyxiao/Bond.git', :branch => 'coredata'
    pod 'Async', :git => 'https://github.com/duemunk/Async.git'
    pod 'SwiftTryCatch', '~> 0.0.1'
    pod 'NSLogger', '~> 1.5', :configuration => ['Debug']

    # Data
    pod 'SugarRecord/CoreData', :git => 'https://github.com/tonyxiao/SugarRecord', :branch => 'develop'
    pod 'Meteor', :git => 'https://github.com/tonyxiao/meteor-ios', :branch => 'dev'
    pod 'RealmSwift', '~> 0.93.2'
    pod 'SwiftyUserDefaults', '~> 1.3'
    pod 'SwiftyJSON', '~> 2.1'

    # Networking
    pod 'Alamofire', '~> 1.2'

    # UI
    pod 'Cartography', '~> 0.5'
    pod 'EDColor', '~> 1.0'

    # ViewModels
    pod 'DateTools', '~> 1.6'
    pod 'FormatterKit/TimeIntervalFormatter', '~> 1.8'

    # Utils
    pod 'SimpleKeychain', '~> 0.4'
    pod 'DTFoundation/DTASN1', '~> 1.7'

    target :CoreTests do
        link_with 'CoreTests'
        pod 'Quick', '~> 0.3.0' # TODO: Upgrade after swift 2.0
        pod 'Nimble', '~> 0.4.0' # TODO: Upgrade after swift 2.0
        pod 'OHHTTPStubs', '~> 4.0.2'
        pod 'SwiftyJSON', '~> 2.1'
    end

    target :Taylr do
        link_with 'Taylr'

        pod 'SwipeView', '~> 1.3'
        pod 'SDWebImage', '~> 3.7'
        pod 'PKHUD', :git => 'https://github.com/tonyxiao/PKHUD' # Fork is needed to work around xcasset compilation issue inside pod
        pod 'XLForm', '~> 3.0'
        pod 'SCRecorder', '~> 2.5'

        pod 'JVFloatLabeledTextField', '~> 1.1'
        pod 'TPKeyboardAvoiding', '~> 1.2'
        pod 'UICollectionViewLeftAlignedLayout', '~> 1.0'
        pod 'CHTCollectionViewWaterfallLayout', '~> 0.9'

        #pod 'Spring', '~> 1.0'
        #pod 'pop', '~> 1.0'
        pod 'RBBAnimation', '~> 0.4.0'

        pod 'INTULocationManager', '~> 3.0'

        # 3rd Party Service SDKs
        pod 'OAuthSwift', '~> 0.3' # TODO: Consider using server based oauth
        pod 'FBSDKLoginKit', '~> 4.3'
        pod 'AnalyticsSwift', '~> 0.1.0'
        pod 'Heap', '~> 2.1'
        pod 'Appsee', '~> 2.1'
        #pod 'BugfenderSDK', :git => 'https://github.com/bugfender/BugfenderSDK-iOS.git', :tag => '0.3.2'

        # Debug only

        pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
#        pod 'SparkInspector', '~> 1.3', :configuration => ['Debug']
    end

    target :TestApp do
        link_with 'TestApp'
        pod 'SCRecorder', '~> 2.5'
        pod 'PKHUD', :git => 'https://github.com/tonyxiao/PKHUD' # Fork is needed to work around xcasset compilation issue inside pod
        pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
    end
end

# Might be useful one day
#pod 'ExSwift', '~> 0.1.9'
