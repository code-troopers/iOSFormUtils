//
//  ValidatedInput.swift
//  application
//
//  Created by Nicolas LELOUP on 18/09/2015.
//  Copyright © 2015 Nicolas LELOUP - Buzznative. All rights reserved.
//
import UIKit

// MARK: Constants
let tfBecameFirstResponderNotifName = "textFieldBecameFirstResponder"
let tfResignedFirstResponderNotifName = "textFieldResignedFirstResponder"
let tfReturnedNotifName = "textFieldReturned"

// MARK: Protocols

/// Delegate protocol for TextInput
public protocol TextInputDelegate {
  func didEnterEditionMode(_ input: TextInput)
  func didExitEditionMode(_ input: TextInput)
}

/// Data source protocol for TextInput
public protocol TextInputDataSource {
  func applyCustomInit(_ input: TextInput)
}

// MARK: Class
/// UITextfield child class for easy form inputs handling
open class TextInput: UITextField {
  // MARK: Class variables
  open var inputDataSource: TextInputDataSource!
  open var textInputDelegate: TextInputDelegate!
  fileprivate var inputAccessory: UIView!
  fileprivate var validationHandler: ValidatedTextInput!
  fileprivate var limit: Int!
  open var validationDelegate: ValidatedTextInputDelegate!
  open var validationDataSource: ValidatedTextInputDataSource!
  
  // MARK: Superclass overrides
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.commonInit()
  }
  
  // MARK: Public own methods
  
  /**
   Main initializer
   */
  open func commonInit() {
    self.delegate = self
    self.validationHandler = self
    
    if let _ = inputDataSource {
      inputDataSource.applyCustomInit(self)
    }
  }
  
  // MARK: Public own methods

  /**
   Applies a custom char limit to the field
   */
  open func setCustomCharLimit(limit: Int?) {
    self.limit = limit
  }
  
  /**
   Stops the current edition.
   */
  open func stopEditing() {
    self.resignFirstResponder()
    NotificationCenter.default.post(name: Notification.Name(rawValue: tfResignedFirstResponderNotifName), object: self)
  }
}

// MARK: Extensions
extension TextInput: UITextFieldDelegate {
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    if let _ = textInputDelegate {
      textInputDelegate.didEnterEditionMode(self)
    }
    if let _ = validationDelegate {
      validationDelegate.didExitErrorMode(self)
    }
    NotificationCenter.default.post(name: Notification.Name(rawValue: tfBecameFirstResponderNotifName), object: self)
  }
  
  public func textFieldDidEndEditing(_ textField: UITextField) {
    if let _ = textInputDelegate {
      textInputDelegate.didExitEditionMode(self)
    }
  }
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    NotificationCenter.default.post(name: Notification.Name(rawValue: tfReturnedNotifName), object: self)
    
    return true;
  }

  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let _ = limit, "" != string {
      return textField.text!.count < limit
    }

    return true
  }
}

