# S10 iOS [![Circle CI](https://circleci.com/gh/s10tv/s10-ios.svg?style=svg&circle-token=a3ef407be4f8b24b7c1fc15926933bb1b7bb8491)](https://circleci.com/gh/s10tv/s10-ios)

## Updating Language
Edit the following two files
[InfoPlist.strings](https://github.com/s10tv/s10-ios/blob/master/Taylr/en.lproj/InfoPlist.strings)
[Localizable.strings](https://github.com/s10tv/s10-ios/blob/master/Taylr/en.lproj/Localizable.strings)

## Getting started
```
brew install mogenerator
gem install cocoapods -v 0.36.0.beta.2
gem install cupertino shenzhen sbconstants
gem install specific_install
gem specific_install -l https://github.com/tonyxiao/xcres.git
pod install
```

Open `Taylr.xcworkspace` and start developing

## Developing

Follow [raywenderlich's swift style guide](https://github.com/raywenderlich/swift-style-guide)

Except we'll leave 4 spaces instead of two space for indentation.

## Make IPAs
By default project should be building with dev configuration. To change, use explicity xcconfig

```
ipa build --xcconfig Configs/[Dev|Beta|Prod].xcconfig
```

## Distribute to Crashlytics
```
export CRASHLYTICS_API_KEY=4cdb005d0ddfebc8865c0a768de9b43c993e9113
export CRASHLYTICS_BUILD_SECRET=83001519164842a323e4d70c5970b041c248835fec59db59b409f5b364e47f72
export CRASHLYTICS_FRAMEWORK_PATH=Pods/CrashlyticsFramework/Crashlytics.framework
ipa distribute:crashlytics -f Taylr.ipa -g team
```

## Convert p12 to pem

```
openssl pkcs12 -in path.p12 -out newfile.crt.pem -clcerts -nokeys
openssl pkcs12 -in path.p12 -out newfile.key.pem -nocerts -nodes
```

After that you have:

certificate in newfile.crt.pem
private key in newfile.key.pem


## Convert cert to pem

```
openssl x509 -inform der -in scripts/certs/apns_prod-com.milasya.Taylr.beta.cer -out betaapns.pem
```
