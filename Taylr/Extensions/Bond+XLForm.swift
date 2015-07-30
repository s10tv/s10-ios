//
//  Bond+XLForm.swift
//  S10
//
//  Created by Tony Xiao on 7/2/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import XLForm
import Bond

private var valueDynamicHandleXLFormRowDescriptor: UInt8 = 0;

extension XLFormRowDescriptor : Bondable {
    public var dynValue: Dynamic<AnyObject?> {
        if let d: AnyObject = objc_getAssociatedObject(self, &valueDynamicHandleXLFormRowDescriptor) {
            return (d as? Dynamic<AnyObject?>)!
        } else {
            let d = InternalDynamic<AnyObject?>(self.value)
            let bond = Bond<AnyObject?>() { [weak self] v in if let s = self { s.value = v } }
            d.bindTo(bond, fire: false, strongly: false)
            d.retain(bond)
            objc_setAssociatedObject(self, &valueDynamicHandleXLFormRowDescriptor, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
    
    public var designatedBond: Bond<AnyObject?> { return dynValue.valueBond }
}

class PrototypeRow : XLFormRowDescriptor {
    let cellReuseId: String
    var configure: ((XLFormBaseCell) -> ())?
    
    init(cellReuseId: String, tag: String? = nil) {
        self.cellReuseId = cellReuseId
        super.init(tag: tag, rowType: nil, title: nil)
    }
    
    override func cellForFormController(formController: XLFormViewController) -> XLFormBaseCell {
        if cell == nil {
            cell = formController.tableView.dequeueReusableCellWithIdentifier(cellReuseId) as! XLFormBaseCell
            configureCellAtCreationTime()
            configure?(cell)
        }
        return cell
    }
}

extension PrototypeRow {
    convenience init(cellReuseId: TableViewCellreuseIdentifier, tag: String? = nil) {
        self.init(cellReuseId: cellReuseId.rawValue, tag: tag)
    }
}