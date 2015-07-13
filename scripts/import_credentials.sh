
# check apple id credentials also exist

if  [[ -z "$APPLE_ID" ]] || \
    [[ -z "$APPLE_ID_PASSWORD" ]] || \
    [[ -z "$DEV_P12_PASS" ]] || \
    [[ -z "$DIST_P12_PASS" ]] || \
    [[ -z "$APPSTORE_PROFILE_NAME" ]] || \
    [[ -z "$APPSTORE_PROFILE_PATH" ]] ; then
    echo "One or more required variables are not set"
    exit 1
fi

PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles/"
KEYCHAIN_NAME="s10.keychain"
KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"
APPSTORE_TEAM_ID=227D5X5CZY
CODE_SIGN=/usr/bin/codesign

## Keys & Certificates

cd "scripts"

security create-keychain -p s10 $KEYCHAIN_NAME
security set-keychain-settings $KEYCHAIN_PATH # Don't autolock / timeout
security list-keychains -d user -s ~/Library/Keychains/login.keychain $KEYCHAIN_PATH # Add to search list

security import "certs/apple_developer_relations.cer"   -k $KEYCHAIN_PATH -T $CODE_SIGN

security import "keys/development.p12" -k $KEYCHAIN_PATH -T $CODE_SIGN -P $DEV_P12_PASS
security import "keys/distribution.p12" -k $KEYCHAIN_PATH -T $CODE_SIGN -P $DIST_P12_PASS



## Provisioning Profiles

mkdir -p "$PROFILE_DIR"

# Temporary fix for cupertino gem being broken by apple updates
# cp profiles/*.* "$PROFILE_DIR"
cd "$PROFILE_DIR"
for profileType in development distribution; do
    echo "Will download $profileType profiles from team with id $APPSTORE_TEAM_ID"
    ios profiles:download:all --type $profileType --team $APPSTORE_TEAM_ID -u $APPLE_ID -p $APPLE_ID_PASSWORD --trace
done

mv $APPSTORE_PROFILE_NAME $APPSTORE_PROFILE_PATH
