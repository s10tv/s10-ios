
# CIRCLE_BRANCH=random
# CIRCLE_BUILD_NUM=1123

case $CIRCLE_BRANCH in
	master) BN=${CIRCLE_BUILD_NUM}d ;;
	beta) 	BN=${CIRCLE_BUILD_NUM}d ;;
	prod) 	BN=${CIRCLE_BUILD_NUM} ;;
	*) 			BN=${CIRCLE_BUILD_NUM}\* ;;
esac
