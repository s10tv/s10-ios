# Ketch-iOS


## Getting started
```
gem install cocoapods -v 0.36.0.beta.2
gem install cupertino shenzhen
pod install
```

Open xcode workspace and start developing

## Make IPAs
By default project should be building with dev configuration. To change, use explicity xcconfig

```
ipa build -s Ketch --xcconfig Ketch/Configs/[Dev|Beta|Prod].xcconfig --xcargs BUNDLE_BUILD="0" --no-archive
```

## Distribute to Crashlytics
```
export CRASHLYTICS_API_KEY=4cdb005d0ddfebc8865c0a768de9b43c993e9113
export CRASHLYTICS_BUILD_SECRET=83001519164842a323e4d70c5970b041c248835fec59db59b409f5b364e47f72
export CRASHLYTICS_FRAMEWORK_PATH=Pods/CrashlyticsFramework/Crashlytics.framework
ipa distribute:crashlytics -f Ketch.ipa -g team
```
