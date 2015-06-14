cat << EOF
`git log -n 1 --pretty=format:%s $CIRCLE_SHA1`
Branch: $CIRCLE_BRANCH [$BN]
Commit: https://github.com/s10tv/s10-ios/commit/$CIRCLE_SHA1
Date: $(date)
EOF