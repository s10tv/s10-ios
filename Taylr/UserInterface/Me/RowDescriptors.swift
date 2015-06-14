//
//  PickerViews.swift
//  Taylr
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import XLForm

class RowDescriptor : XLFormPrototypeRowDescriptor {
    
    var formatBlock: (AnyObject -> String)?
    var transformBlock: (String? -> AnyObject?)?
    var inputView: UIView?
    
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

    // Hacks..
    func beginEditing() { }
    
    func endEditing() { }
}

class HeightRowDescriptor : RowDescriptor {

    let picker = UIPickerView()
    let ftToCm: CGFloat = 30.48
    let inToCm: CGFloat = 2.54
    let feets = Array(4...7)
    let inches = Array(0...11)
    
    override init() {
        super.init()
    }
    
    override init(cellReuseIdentifier: String!) {
        super.init(cellReuseIdentifier: cellReuseIdentifier)
        picker.delegate = self
        picker.dataSource = self
        inputView = picker
    }
    
    // Ghetoo height calculation code...
    var height: Int {
        get { return value as! Int }
        set { value = newValue }
    }
    var imperialHeight: (feet: Int, inches: Int) {
        get {
            let feet = Int(floor(height.f / ftToCm))
            let inches = Int(ceil(height.f -  feet.f * ftToCm) / inToCm)
            // HACK ALERT: Need to figure out how to properly convert between centimeter / feet + inches without
            // rounding errors and consistently round up / down so we don't get something like 3'12'
            // Temp hack to fix crash https://fabric.io/ketch-app/ios/apps/com.milasya.ketch.dev/issues/553818515141dcfd8f8be02b
            if inches == 12 {
                return (feet + 1, 0)
            }
            return (feet, inches)
        }
        set {
            height = Int(newValue.feet.f * ftToCm + newValue.inches.f * inToCm)
        }
    }

    override func beginEditing() {
        if value != nil {
            let (f, i) = imperialHeight
            if f < 4 || f > 7 || i < 0 || i > 11 {
                Log.error("Feet and inches outside range f = \(f) i = \(i)")
                return
            }
            picker.selectRow(find(feets, f)!, inComponent: 0, animated: false)
            picker.selectRow(find(inches, i)!, inComponent: 1, animated: false)
        }
    }
    
    override func endEditing() {
        if picker.selectedRowInComponent(0) < 0 || picker.selectedRowInComponent(1) < 0 {
            return
        }
        let f = feets[picker.selectedRowInComponent(0)]
        let i = inches[picker.selectedRowInComponent(1)]
        imperialHeight = (f, i)
        if let cell = valueForKey("cell") as? XLFormBaseCell {
            cell.update()
        }
    }
}

extension HeightRowDescriptor : UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if component == 0 {
            return "\(feets[row]) feet"
        } else {
            return "\(inches[row]) inches"
        }
    }
}

extension HeightRowDescriptor : UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? feets.count : inches.count
    }
}

class GenderPrefRowDescriptor : RowDescriptor {
    let picker = UIPickerView()
    let choices = ["men", "women", "both"]
    
    override init() {
        super.init()
    }
    
    override init(cellReuseIdentifier: String!) {
        super.init(cellReuseIdentifier: cellReuseIdentifier)
        picker.delegate = self
        picker.dataSource = self
        inputView = picker
    }
    
    override func beginEditing() {
        if let choice = value as? String {
            picker.selectRow(find(choices, choice)!, inComponent: 0, animated: false)
        }
    }
    
    override func endEditing() {
        if picker.selectedRowInComponent(0) < 0 {
            return
        }
        value = choices[picker.selectedRowInComponent(0)]
        if let cell = valueForKey("cell") as? XLFormBaseCell {
            cell.update()
        }
    }
}

extension GenderPrefRowDescriptor : UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return choices[row].capitalizedString
    }
}

extension GenderPrefRowDescriptor : UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
}