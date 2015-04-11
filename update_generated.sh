cd Ketch

# Regenerate CoreData model files
mogenerator -m Models/Ketch.xcdatamodeld/Ketch.xcdatamodel/ --human-dir Models --machine-dir Generated/_Models --swift

# Regenerate storyboard constants
sbconstants -s Base.lproj/ -w -d > Generated/SBConstants.swift

# Regenerate image and string name constants
# Exclude generic Images.xcassets that come from including Pods resources manually
xcres build -v -x "Pods/**" ../ Generated/R
