#!/bin/bash

ROOT=$(dirname "$0")

# Regenerate CoreData model files
cd "Core"
mogenerator --swift --template-path "../scripts/motemplates" \
            -m Models/Models.xcdatamodeld/Models.xcdatamodel/ --human-dir Models --machine-dir Models/_Models

# Regenerate Taylr assets
cd "../Taylr"
# Regenerate storyboard constants
sbconstants -s Base.lproj/ -w -d > Generated/SBConstants.swift

# Regenerate image and string name constants
# Exclude generic Images.xcassets that come from including Pods resources manually
xcres build -v --target Taylr -x "Pods/**" ../ Generated/R
