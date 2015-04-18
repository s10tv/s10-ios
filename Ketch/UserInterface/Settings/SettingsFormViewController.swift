//
//  SettingsFormViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import XLForm

class RowDescriptor : XLFormPrototypeRowDescriptor {
    
    var formatBlock: (AnyObject -> String)?
    var transformBlock: (String? -> AnyObject?)?
    
    var formattedValue: String? {
        return value != nil ? formatBlock?(value!) : nil
    }
    
    func transformAndSetValue(preValue: String?) {
        value = transformBlock != nil ? transformBlock!(preValue) : preValue
    }
    
    // Bit of a hack to work around issue with swift compiler crashing...
    func updateCellWithValue(value: AnyObject?) {
        self.value = value
        if let cell = valueForKey("cell") as? XLFormBaseCell {
            cell.rowDescriptor = self
            if let cell = cell as? SettingsTextCell {
                cell.forceUpdateHeight()
            }
        }
    }
}

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
            let row = RowDescriptor(cellReuseIdentifier: getReuseId(item.type).rawValue)
            row.tag = item.type.rawValue
            row.title = item.iconName
            row.noValueDisplayText = item.formatBlock?(nil)
            row.formatBlock = item.formatBlock
            row.disabled = !item.editable
            row.value = item.value.current
            item.value.signal.skip(1).subscribeNext {
                row.updateCellWithValue($0)
            }
            println("Creating row \(row.tag) value: \(row.value)")
            return row
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func didSelectFormRow(formRow: XLFormRowDescriptor!) {
        // TODO: Can this be done in storyboard instead as segue
        if let type = SettingsItem.ItemType(rawValue: formRow.tag) {
            if type == .ProfilePhoto || type == .Name {
                parentViewController?.performSegue(.Main_Profile)
            }
        }
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        if let type = SettingsItem.ItemType(rawValue: formRow.tag) {
            viewModel.updateItem(type, newValue: newValue)
        }
    }
    
}
