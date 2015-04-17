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
    
    var viewModel: SettingsViewModel!
    
    override func viewDidLoad() {
        assert(User.currentUser() != nil, "Current user must exist before showing settings")
        viewModel = SettingsViewModel(currentUser: User.currentUser()!, meta: Meteor.meta)
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
        func getReuseId(type: SettingsItem.ItemType) -> TableViewCellreuseIdentifier {
            switch type {
            case .Name:
                return .SettingsLabelCell
            case .ProfilePhoto:
                return .SettingsPhotoCell
            default:
                return .SettingsTextCell
            }
        }
        return viewModel.items.map { item in
            let row = XLFormPrototypeRowDescriptor(cellReuseIdentifier: getReuseId(item.type).rawValue)
            row.tag = item.type.rawValue
            row.title = item.iconName
            row.noValueDisplayText = item.formatBlock?(nil)
            row.disabled = (item.updateBlock == nil)
            item.value.signal.subscribeNext { row.value = $0 }
            println("Creating row \(row.tag) value: \(row.value)")
            return row
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}




