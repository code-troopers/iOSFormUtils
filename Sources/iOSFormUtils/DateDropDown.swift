//
//  DateDropDown.swift
//  application
//
//  Created by Nicolas LELOUP on 25/02/2017.
//  Copyright © 2017 Nicolas LELOUP - Buzznative. All rights reserved.
//

import Foundation
import UIKit

public protocol DateDropDownDelegate {
  func dropDown(_ dropDown: DateDropDown!, selectedDate value: Date!)
}

open class DateDropDown: DropDown {
  public var selectedDate: Date! {
    didSet {
      if selectedDate != oldValue {
        self.refreshDateView()
      }
    }
  }
  public var dateDropDownDelegate: DateDropDownDelegate!

  func refreshDateView() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = self.dateFormat

    titleTextField.text = dateFormatter.string(from: selectedDate)
    if let _ = self.dataSource {
      titleTextField.textColor = self.uiDataSource.getTextColor()
      titleTextField.font = UIFont(name: self.uiDataSource.getFontName(), size: self.uiDataSource.getFontSize())
    }
  }

  override open func loadView() {
    super.loadView()
    picker = SBPickerSwiftSelector(mode: .dateDefault)
    /*
 picker.pickerType = .date
    picker.onlyDayPicker = true
    picker.datePickerType = .onlyDay
 */
  }
}
