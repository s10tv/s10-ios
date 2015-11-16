"$CRASHLYTICS_FRAMEWORK_PATH/submit" $CRASHLYTICS_API_KEY $CRASHLYTICS_BUILD_SECRET \
                                    -ipaPath $CIRCLE_ARTIFACTS/${BN}.ipa \
                                    -groupAliases $CRASHLYTICS_BETA_TEAM \
                                    -notifications $CRASHLYTICS_BETA_NOTIFICATIONS \
                                    -notesPath $CIRCLE_ARTIFACTS/release_notes.txt