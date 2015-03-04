
# check apple id credentials also exist

if  [[ -z "$APPLE_ID" ]] || \
    [[ -z "$APPLE_ID_PASSWORD" ]] || \
    [[ -z "$DEV_KEY_PASSPHRASE" ]] || \
    [[ -z "$DISTRIBUTION_KEY_PASSPHRASE" ]]; then
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
security import "certs/development.cer"                 -k $KEYCHAIN_PATH -T $CODE_SIGN
security import "certs/distribution.cer"                -k $KEYCHAIN_PATH -T $CODE_SIGN
security import "certs/distribution_enterprise.cer"     -k $KEYCHAIN_PATH -T $CODE_SIGN

# TODO: Combine private key and certificate into a single p12 file
# Each certificate should have its own private key anyways
security import "keys/development.p12"  -k $KEYCHAIN_PATH -T $CODE_SIGN -P $DEV_KEY_PASSPHRASE
security import "keys/distribution.p12" -k $KEYCHAIN_PATH -T $CODE_SIGN -P $DISTRIBUTION_KEY_PASSPHRASE

## Provisioning Profiles

mkdir -p "$PROFILE_DIR"
cd "$PROFILE_DIR"

for profileType in development distribution; do
    for teamId in $APPSTORE_TEAM_ID $ENTERPRISE_TEAM_ID; do
        ios profiles:download:all --type $profileType --team $teamId -u $APPLE_ID -p $APPLE_ID_PASSWORD
    done
done
