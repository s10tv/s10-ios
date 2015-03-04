# Ketch-iOS [![Circle CI](https://circleci.com/gh/Ketchteam/ketch-ios/tree/master.svg?style=svg&circle-token=fd4466969ab998ed3ab739c0a526fade067abe24)](https://circleci.com/gh/Ketchteam/ketch-ios/tree/master)

## Getting started
```
brew install mogenerator
gem install cocoapods -v 0.36.0.beta.2
gem install cupertino shenzhen sbconstants xcres
pod install
```

Open `Ketch.xcworkspace` and start developing

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
ipa distribute:crashlytics -f Ketch.ipa -g team
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
openssl x509 -inform der -in scripts/certs/apns_prod-com.milasya.ketch.beta.cer -out betaapns.pem
```
