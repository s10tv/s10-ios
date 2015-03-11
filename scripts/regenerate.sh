cd Ketch

# Regenerate CoreData model files
mogenerator -m Models/Ketch.xcdatamodeld/Ketch.xcdatamodel/ --human-dir Models --machine-dir Models/_Models --swift

# Regenerate storyboard constants
sbconstants -s Base.lproj/ -w -d > Resources/SBConstants.swift

# Regenerate image and string name constants
xcres build -v -x "Helpshift*" -x "HS*" -x "JSQ*" ../ Resources/R
