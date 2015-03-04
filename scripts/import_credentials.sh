
if [ -z "$DEV_KEY_PASSPHRASE" ]; then
    echo "DEV_KEY_PASSPHRASE not set"
    exit 1
fi
if [ -z "$DISTRIBUTION_KEY_PASSPHRASE" ]; then
    echo "DISTRIBUTION_KEY_PASSPHRASE not set"
    exit 1
fi

## Add keys & Provisioning profiles

cd "scripts"

# Keychain

KEYCHAIN_NAME="ios-build.keychain"
KEYCHAIN_PATH="$HOME/Library/Keychains/$KEYCHAIN_NAME"
CODE_SIGN=/usr/bin/codesign

security create-keychain $KEYCHAIN_NAME
security set-keychain-settings $KEYCHAIN_PATH # Don't autolock / timeout
security list-keychains -d user -s ~/Library/Keychains/login.keychain $KEYCHAIN_PATH # Add to search list

security import "certs/apple_developer_relations.cer" 	-k $KEYCHAIN_PATH -T $CODE_SIGN
security import "certs/development.cer" 				-k $KEYCHAIN_PATH -T $CODE_SIGN
security import "certs/distribution.cer" 				-k $KEYCHAIN_PATH -T $CODE_SIGN
security import "certs/distribution_enterprise.cer" 	-k $KEYCHAIN_PATH -T $CODE_SIGN

security import "keys/development.p12" 	-k $KEYCHAIN_PATH -T $CODE_SIGN -P $DEV_KEY_PASSPHRASE
security import "keys/distribution.p12" -k $KEYCHAIN_PATH -T $CODE_SIGN -P $DISTRIBUTION_KEY_PASSPHRASE

# Provisioning Profiles

PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles/"
mkdir -p "$PROFILE_DIR"
cp -r "profiles/" "$PROFILE_DIR"
