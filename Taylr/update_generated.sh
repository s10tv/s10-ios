#!/bin/bash

# Make sure we are in the right working directory
cd "$(dirname "$0")"

# Regenerate CoreData model files
mogenerator -m Models/Models.xcdatamodeld/Models.xcdatamodel/ --human-dir Models --machine-dir Generated/_Models --swift

# Regenerate storyboard constants
sbconstants -s Base.lproj/ -w -d > Generated/SBConstants.swift

# Regenerate image and string name constants
# Exclude generic Images.xcassets that come from including Pods resources manually
xcres build -v --target Taylr -x "Pods/**" ../ Generated/R
