//
//  SettingsFormViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import XLForm
import Core

class SettingsFormViewController : XLFormTableViewController {
    
    var viewModel: SettingsViewModel!
    
    override func viewDidLoad() {
        assert(User.currentUser() != nil, "Current user must exist before showing settings")
        viewModel = SettingsViewModel(currentUser: User.currentUser()!, settings: Meteor.settings)
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
        func getRow(type: SettingsItem.ItemType) -> RowDescriptor {
            switch type {
            case .Height:
                return HeightRowDescriptor(cellReuseIdentifier: getReuseId(type).rawValue)
            case .GenderPreference:
                return GenderPrefRowDescriptor(cellReuseIdentifier: getReuseId(type).rawValue)
            default:
                return RowDescriptor(cellReuseIdentifier: getReuseId(type).rawValue)
            }
        }
        return viewModel.items.map { item in
            let row = getRow(item.type)
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
    
    // MARK: -
    
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
