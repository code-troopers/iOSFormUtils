//
//  DropDown.swift
//  application
//
//  Created by Nicolas LELOUP on 25/02/2017.
//  Copyright © 2017 Nicolas LELOUP - Buzznative. All rights reserved.
//

import Foundation
import UIKit
import UIKitExtensions
import SnapKit

public protocol DropDownDataSource {
  func controllerForDropDownDisplaying(_ dropDown: DropDown) -> UIViewController
  func valuesForDropDown(_ dropDown: DropDown) -> [String]
  func selectedIndexForDropDown(_ dropDown: DropDown) -> Int?
  func placeholderKeyForDropDown(_ dropDown: DropDown) -> String?
  func isRequired(_ dropDown: DropDown) -> Bool
}

public protocol DropDownUIDataSource {
  func getTextColor() -> UIColor
  func getPlaceholderColor() -> UIColor
  func getFontName() -> String
  func getFontSize() -> CGFloat
  func getRightIcon() -> UIImage?
  func getButtonsColor() -> UIColor
}

public protocol DropDownDelegate {
  func dropDown(_ dropDown: DropDown!, selectedValue value: String!, index: Int)

  func dropDownDeselectedValue(_ dropDown: DropDown!)
}

open class DropDown: OwnView {
  var dateFormat = "dd/MM/y"

  public var delegate: DropDownDelegate!
  public var uiDataSource: DropDownUIDataSource! {
    didSet {
      updateUI()
    }
  }
  public var dataSource: DropDownDataSource!

  var picker: SBPickerSwiftSelector? //FIXME CG = SBPickerSwiftSelector.picker()
  var values: [String]!
  var currentTextField: TextInput!
  public var selectedIndex: Int!

  var mainColor: UIColor = UIColor.blue

  var rightIcon: UIImageView!
  open var titleTextField: TextInput!
  var mainButton: UIButton!

  override open func loadView() {
    self.titleTextField = TextInput(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    self.titleTextField.borderStyle = .none
    self.addSubview(self.titleTextField)
    
    rightIcon = UIImageView(frame: CGRect())
    rightIcon.contentMode = UIView.ContentMode.center
    self.addSubview(rightIcon)
    
    mainButton = UIButton(type: .custom)
    mainButton.addTarget(self, action: #selector(DropDown.mainButtonTouched(_:)), for: .touchUpInside)
    self.addSubview(mainButton)
    
    titleTextField.snp.makeConstraints { make in
      make.leading.equalTo(self.snp.leading)
      make.height.equalTo(self)
      make.centerY.equalTo(self)
      make.trailing.equalTo(rightIcon.snp.leading)
    }
    rightIcon.snp.makeConstraints { make in
      make.trailing.equalTo(self)
      make.height.equalTo(self)
      make.width.equalTo(self.snp.height)
      make.centerY.equalTo(self)
    }
    mainButton.snp.makeConstraints { maker in
      maker.edges.equalTo(self)
    }
    self.layoutIfNeeded()
    self.layoutSubviews()

    picker = SBPickerSwiftSelector(mode: .text)
    picker?.doneButton?.title = "OK"
    picker?.doneButton?.tintColor = mainColor
    picker?.cancelButton?.title = "Annuler"
    picker?.cancelButton?.tintColor = mainColor

    updateUI()

    reloadData()

    NotificationCenter.default.addObserver(
        self,
        selector: #selector(DropDown.textFieldBecameFirstResponder(_:)),
        name: NSNotification.Name(rawValue: "textFieldBecameFirstResponder"),
        object: nil
    )
  }

  func updateUI() {
    if let _ = dataSource, let _ = uiDataSource {
      picker?.doneButton?.tintColor = uiDataSource.getButtonsColor()
      picker?.cancelButton?.tintColor = uiDataSource.getButtonsColor()
      
      if let existingPlaceholder = dataSource.placeholderKeyForDropDown(self) {
        updatePlaceholderWithValue(existingPlaceholder)
      }
      
      if let _ = uiDataSource.getRightIcon() {
        rightIcon.image = uiDataSource.getRightIcon()
      }
    }
  }

  func updatePlaceholderWithValue(_ value: String) {
    titleTextField.attributedPlaceholder = NSAttributedString(
        string: value,
        attributes: [
            NSAttributedString.Key.foregroundColor: self.uiDataSource.getPlaceholderColor(),
            NSAttributedString.Key.font: UIFont(name: self.uiDataSource.getFontName(), size: self.uiDataSource.getFontSize())!
        ]
    )
  }

  func updateSelectedIndex(_ newIndex: Int) {
    selectedIndex = newIndex
    picker?.pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
    if let data: [String] = picker?.data as? [String] {
      pickerSelector(picker, selectedValue: data[selectedIndex], index: selectedIndex)
        picker!.pickerView.delegate?.pickerView?(picker!.pickerView, didSelectRow: selectedIndex, inComponent: 0)
    }
  }

  func resetValue() {
    titleTextField.text! = ""
  }

  public func reloadData() {
    updateUI()
    if let itsDataSource = dataSource {
      var values: [String] = itsDataSource.valuesForDropDown(self)
      var offset = 0
      if nil != dataSource && !dataSource.isRequired(self) {
        values.insert("-", at: 0)
        offset = 1
      }

      picker?.data = values
      if let dataSourceSelectedIndex: Int = itsDataSource.selectedIndexForDropDown(self) {
        updateSelectedIndex(dataSourceSelectedIndex + offset)
      }
    }
  }

  func presentDropDown() {
    if let itsDataSource = dataSource {
      if let textField = currentTextField {
        textField.resignFirstResponder()
      }
        picker?.present(into: itsDataSource.controllerForDropDownDisplaying(self))
    }
  }

  @objc func mainButtonTouched(_ sender: AnyObject) {
    presentDropDown()
  }

  @objc func textFieldBecameFirstResponder(_ notification: Notification) {
    if let textField: TextInput = notification.object as? TextInput {
      if textField != titleTextField {
        currentTextField = textField
      } else {
        currentTextField = nil
      }
    }
  }
}

extension DropDown /*: SBPickerSelectorDelegate */{
  public func pickerSelector(_ selector: SBPickerSwiftSelector!, selectedValue value: String!, index idx: Int) {
    let required = (nil != dataSource && !dataSource.isRequired(self))
    var offset = 0
    if (required && 0 != idx) || !required {
      titleTextField.text = value
      titleTextField.textColor = self.uiDataSource.getTextColor()
      titleTextField.font = UIFont(name: self.uiDataSource.getFontName(), size: self.uiDataSource.getFontSize())
      if required {
        offset = 1
      }

      if let itsDelegate = delegate {
        itsDelegate.dropDown(self, selectedValue: value, index: idx - offset)
        self.selectedIndex = idx - offset
      }
    } else {
      resetValue()

      if let itsDelegate = delegate {
        itsDelegate.dropDownDeselectedValue(self)
        self.selectedIndex = nil
      }
    }
  }

  public func pickerSelector(_ selector: SBPickerSwiftSelector!, dateSelected date: Date!) {
    if SBPickerSwiftSelector.Mode.dateDefault == picker?.pickerMode {
      if let _ = date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormat

        titleTextField.text = dateFormatter.string(from: date)
        titleTextField.textColor = self.uiDataSource.getTextColor()
        titleTextField.font = UIFont(name: self.uiDataSource.getFontName(), size: self.uiDataSource.getFontSize())

        if let dateSelf: DateDropDown = self as? DateDropDown {
          if let dateDropDownDelegate: DateDropDownDelegate = dateSelf.dateDropDownDelegate {
            dateDropDownDelegate.dropDown(dateSelf, selectedDate: date)
            dateSelf.selectedDate = date
          }
        }
      }
    }
  }
}
