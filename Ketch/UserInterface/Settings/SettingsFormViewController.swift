//
//  SettingsFormViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import XLForm



class SettingsFormViewController : XLFormTableViewController {
    
    override func viewDidLoad() {
        // Configure form before viewDidLoad so that everyting's already laid out prior to
        // view appear and thus avoiding row insertion unwanted animation
        form = createForm()
        super.viewDidLoad()
    }
    
    func createForm() -> XLFormDescriptor {
        let form = XLFormDescriptor()
        let section = XLFormSectionDescriptor()
        createRows().each { section.addFormRow($0) }
        form.addFormSection(section)
        return form
    }
    
    func createRows() -> [XLFormPrototypeRowDescriptor] {
        let photoRow = XLFormPrototypeRowDescriptor(cellReuseIdentifier: "SettingsPhotoCell")
        let ageRow = XLFormPrototypeRowDescriptor(cellReuseIdentifier: "SettingsTextCell")
        let heightRow = XLFormPrototypeRowDescriptor(cellReuseIdentifier: "SettingsTextCell")
        let aboutRow = XLFormPrototypeRowDescriptor(cellReuseIdentifier: "SettingsTextCell")
        
        return [photoRow, ageRow, heightRow, aboutRow]
    }
}