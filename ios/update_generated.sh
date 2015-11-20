#!/bin/bash

cd "Taylr"

# Regenerate storyboard constants
sbconstants -s ./ -w -d > Support/SBConstants.swift

# Regenerate image and string name constants
# Exclude generic Images.xcassets that come from including Pods resources manually
xcres build -v --target Taylr -x "Pods/**" ../ Support/R
