
# check apple id credentials also exist

if  [[ -z "$APPLE_ID" ]] || \
    [[ -z "$APPLE_ID_PASSWORD" ]] || \
    [[ -z "$DEV_P12_PASS" ]] || \
    [[ -z "$DIST_P12_PASS" ]] || \
    [[ -z "$ENT_DIST_P12_PASS" ]]; then
    echo "One or more required variables are not set"
    exit 1
fi

PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles/"
KEYCHAIN_NAME="milasya.keychain"
KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"
APPSTORE_TEAM_ID=9D38KEC36B
ENTERPRISE_TEAM_ID=M8L4RJ733D
CODE_SIGN=/usr/bin/codesign

## Keys & Certificates

cd "scripts"

security create-keychain -p ketchy $KEYCHAIN_NAME
security set-keychain-settings $KEYCHAIN_PATH # Don't autolock / timeout
security list-keychains -d user -s ~/Library/Keychains/login.keychain $KEYCHAIN_PATH # Add to search list

security import "certs/apple_developer_relations.cer"   -k $KEYCHAIN_PATH -T $CODE_SIGN

security import "keys/development.p12" -k $KEYCHAIN_PATH -T $CODE_SIGN -P $DEV_P12_PASS
security import "keys/distribution.p12" -k $KEYCHAIN_PATH -T $CODE_SIGN -P $DIST_P12_PASS
# Temporary hack to work around the issue where resigning doesn't work because both enterprise
# and app store signing identities are called "iPhone Distribution: Milasya Inc." and it fails on
# ambiguous identity when signing
if [[ $CIRCLE_BRANCH != "prod" ]]; then
  security import "keys/enterprise_distribution.p12" -k $KEYCHAIN_PATH -T $CODE_SIGN -P $ENT_DIST_P12_PASS
fi

## Provisioning Profiles

mkdir -p "$PROFILE_DIR"

# Temporary fix for cupertino gem being broken by apple updates
cp profiles/*.* "$PROFILE_DIR"
# cd "$PROFILE_DIR"
# for profileType in development distribution; do
#     for teamId in $APPSTORE_TEAM_ID $ENTERPRISE_TEAM_ID; do
#         echo "Will download $profileType profiles from team with id $teamId"
#         ios profiles:download:all --type $profileType --team $teamId -u $APPLE_ID -p $APPLE_ID_PASSWORD --trace
#     done
# done
