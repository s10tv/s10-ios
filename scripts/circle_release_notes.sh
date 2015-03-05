cat << EOF
`git log -n 1 --pretty=format:%s $CIRCLE_SHA1`
Branch: $CIRCLE_BRANCH [$BN]
Commit: https://github.com/Ketchteam/ketch-ios/commit/$CIRCLE_SHA1
Date: $(date)
EOF