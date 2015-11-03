platform :ios, '8.0'

source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

target :Core do
    link_with 'Core'
    # Foundation
    pod 'ReactiveCocoa', '~> 4.0.2-alpha-1'
    pod 'Async', :git => 'https://github.com/duemunk/Async.git', :commit => 'abe23c18d8d3a708a325b5db10231388e1ca5b88'
    pod 'NSLogger', '~> 1.5', :configuration => ['Debug']

    # Data
    pod 'SugarRecord/CoreData', :git => 'https://github.com/tonyxiao/SugarRecord', :branch => 'swift2.0'
    pod 'Meteor', :git => 'https://github.com/tonyxiao/meteor-ios', :branch => 'dev'
    pod 'LayerKit', '~> 0.17'
    pod 'RealmSwift', '~> 0.95'
    pod 'SwiftyJSON', '~> 2.3'
    pod 'ObjectMapper', '~> 0.18'

    # Networking
    pod 'Alamofire', '~> 3.1'

    # UI
    pod 'Cartography', '~> 0.6'
    pod 'EDColor', '~> 1.0'
    # ViewModels
    pod 'DateTools', '~> 1.7'
    pod 'FormatterKit/TimeIntervalFormatter', '~> 1.8'

    # Utils
    pod 'SimpleKeychain', '~> 0.4'
    pod 'DTFoundation/DTASN1', '~> 1.7'

    target :CoreTests do
        link_with 'CoreTests'
        pod 'Quick', '~> 0.6'
        pod 'Nimble', '~> 3.0'
        pod 'OHHTTPStubs', '~> 4.3'
    end

    target :Taylr do
        link_with 'Taylr'
        pod 'React', :path => 'app/node_modules/react-native', :subspecs => [
          'Core',
          'RCTImage',
          'RCTNetwork',
          'RCTText',
          'RCTWebSocket',
          # Add any other subspecs you want to use in your project
        ]

        pod 'SwipeView', '~> 1.3'
        pod 'SDWebImage', '~> 3.7'
        pod 'PKHUD', :git => 'https://github.com/tonyxiao/PKHUD' # Fork is needed to work around xcasset compilation issue inside pod
        pod 'SCRecorder', '2.5.3' # ScaleAspectFill bug

        # Fork is needed to work around the crash
        pod 'DZNEmptyDataSet', :git => 'https://github.com/dzenbot/DZNEmptyDataSet.git'
        # Master since cocoapods is pretty outdated for some reason
        pod 'MLPAutoCompleteTextField', :git => 'https://github.com/EddyBorja/MLPAutoCompleteTextField.git'
        pod 'AMPopTip', '~> 0.9'
        pod 'JSBadgeView', '~> 1.4'
        pod 'JVFloatLabeledTextField', '~> 1.1'
        pod 'TPKeyboardAvoiding', '~> 1.2'
        pod 'CHTCollectionViewWaterfallLayout', '~> 0.9'
        pod 'JBKenBurnsView', '~> 1.0'

        # 3rd Party Service SDKs
        pod 'FBSDKLoginKit', '~> 4.6'
        pod 'Fabric', '~> 1.5'
        pod 'Crashlytics', '~> 3.3'
        pod 'TwitterCore', '~> 1.11'
        pod 'Digits', '~> 1.11'
        pod 'Ouralabs', '~> 2.6'
        pod 'Mixpanel', '~> 2.9'
        pod 'AnalyticsSwift', '~> 0.2'
        pod 'Amplitude-iOS', '~> 3.1'
        pod 'Atlas', '~> 1.0.13'
        pod 'UXCam', '~> 2.3'

        # Debug only

        pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
#        pod 'SparkInspector', '~> 1.3', :configuration => ['Debug']

        post_install do |installer|
            app_plist = "Taylr/Taylr-Info.plist"
            plist_buddy = "/usr/libexec/PlistBuddy"
            version = `#{plist_buddy} -c "Print CFBundleShortVersionString" #{app_plist}`.strip
            puts "Updating CocoaPods' version numbers to #{version}"

            installer.pods_project.targets.each do |target|
                `#{plist_buddy} -c "Set CFBundleShortVersionString #{version}" "Pods/Target Support Files/#{target}/Info.plist"`
            end
        end
    end

    target :TestApp do
        link_with 'TestApp'
        pod 'SCRecorder', '2.5.3'
        pod 'SDWebImage', '~> 3.7'
        pod 'Reveal-iOS-SDK', '~> 1.5', :configuration => ['Debug']
    end
end
