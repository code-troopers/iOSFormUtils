//
//  Form.swift
//  Pods
//
//  Created by Nicolas LELOUP on 15/09/2016.
//
//

import Foundation
import SnapKit
import UIKit

// MARK: Protocols

/// Delegate protocol to handle form submitting
public protocol FormDelegate {
  /**
   Triggered when the keybiard return key is touched on the last field.
   */
  func goReturnKeyTouched()
  
  /*
   Returns the first input of a form
   
   - Parameter form: The form
   
   - Return: The first input.
   */
  func getFirstInput(_ form: Form) -> TextInput
  
  /*
   Returns the following input of a form input
   
   - Parameter form: The form
   - Parameter currentInput: The current input
   
   - Return: If the current input is the last one, nil. If not, the following input.
   */
  func getNextInput(_ form: Form, currentInput: TextInput) -> TextInput?
}

public protocol FormDataSource {
  func getContainer() -> UIView
}

// MARK: Class
/// UIScrollView child class for forms handling
open class Form: UIScrollView {
  // MARK: Class properties
  /// The original frame of the form
  var originalFrame: CGRect!
  
  /// Flag to stor either it has been scrolled because of keyboard appearing
  var viewScrolledForKeyboard = false
  
  /// The keyboard frame height
  var keyboardViewHeight: CGFloat = 216
  var currentOffSet: CGFloat = 0
  
  /// The stored delegate
  public var formDelegate: FormDelegate!
  
  public var formDataSource: FormDataSource!
  
  /// The current input which has been focused
  fileprivate var currentInput: TextInput! {
    didSet {
      if oldValue != currentInput && nil != currentInput {
        minimizeScrollingZone(currentInput)
      }
    }
  }
  
  // MARK: Superclass overrides
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required public init(coder: NSCoder) {
    super.init(coder: coder)!
    commonInit()
  }
  
  override open func addSubview(_ view: UIView) {
    super.addSubview(view)
    
    if let input: TextInput = view as? TextInput {
      input.textInputDelegate = self
    }
  }
  
  // MARK: Private own methods
  
  /**
   Custom initializer
   */
  fileprivate func commonInit() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Form.keyboardShown(_:)),
        name: UIResponder.keyboardDidShowNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Form.keyboardHidden(_:)),
        name: UIResponder.keyboardDidHideNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Form.textFieldReturnedFired(_:)),
      name: NSNotification.Name(rawValue: tfReturnedNotifName),
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Form.textFieldResignedFirstResponderFired(_:)),
      name: NSNotification.Name(rawValue: tfResignedFirstResponderNotifName),
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Form.textFieldBecameFirstResponder(_:)),
      name: NSNotification.Name(rawValue: tfBecameFirstResponderNotifName),
      object: nil
    )
//    if let _ = formDelegate {
//      currentInput = formDelegate.getFirstInput(self)
//    }
  }
  
  public func reloadData() {
    if let _ = formDelegate {
      currentInput = formDelegate.getFirstInput(self)
    }
    self.handleInputsReturnKeys()
    self.resetScrollingZone()
  }
  
  /**
   Handles return keys type for inputs
   */
  private func handleInputsReturnKeys() {
    let inputs = getOrderedInputs()
    for input in inputs {
      if let input: TextInput = input as? TextInput, nil == input.textInputDelegate {
        input.textInputDelegate = self
      }

      if let textField: UITextField = input as? UITextField {
        if textField == inputs.last as? UITextField {
          textField.returnKeyType = .go
        } else {
          textField.returnKeyType = .next
        }
      }
    }
  }
  
  /**
   Updates the scrollview frame when keyboard appears.
   Scrolls to make the current field visible.
   */
  fileprivate func minimizeScrollingZone(_ input: TextInput) {
    if (!viewScrolledForKeyboard) {
      viewScrolledForKeyboard = true
      if let _ = formDataSource {
        self.snp.updateConstraints({ (maker) in
          maker.bottom.equalTo(formDataSource!.getContainer().snp.bottom).offset(-keyboardViewHeight)
        })
      }
    }
 
//    let offSetToScroll = input.frame.origin.y - self.frame.height/2 + input.frame.height/2
//    if 0 < offSetToScroll {
//      UIView.animate(withDuration: 0.2, animations: {
//        self.contentOffset = CGPoint(x: 0, y: min(offSetToScroll, self.contentSize.height - self.frame.height + input.frame.height/2))
//      })
//    }
  }
  
  /**
   Resets the scrolling zone to its original value.
   */
  open func resetScrollingZone() {
    viewScrolledForKeyboard = false
    if let _ = formDataSource {
      self.snp.updateConstraints({ (maker) in
        maker.bottom.equalTo(formDataSource!.getContainer().snp.bottom)
      })
    }
  }
  
  // MARK: NSNotification listeners
  
  /**
   If input attached to the notification is the last of the form, submit is triggered. If not, focus is given to the following input.
   
   - Parameter notification: the received notification.
   */
    @objc func textFieldReturnedFired(_ notification: Notification) {
    if let textfield = notification.object as? TextInput {
      if isLastInput(textfield) {
        textfield.stopEditing()
        resetScrollingZone()
        if let _ = formDelegate {
          formDelegate.goReturnKeyTouched()
        }
      } else {
        if let _ = formDelegate {
          formDelegate.getNextInput(self, currentInput: currentInput)?.becomeFirstResponder()
        }
      }
    }
  }

  /**
   Scrolling zone is layered with its original when text field resigned first respnder.

   - Parameter notification: the received notification.
   */
    @objc func textFieldResignedFirstResponderFired(_ notification: Notification) {
    resetScrollingZone()
  }
  
  /**
   Updates the keyboard height with the right value.
   
   - Parameter notification: the received notification
   */
    @objc func keyboardShown(_ notification: Notification) {
    let info  = (notification as NSNotification).userInfo!
    let value: AnyObject = info[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject
    
    let rawFrame = value.cgRectValue
    let keyboardFrame = self.convert(rawFrame!, from: nil)

    keyboardViewHeight = keyboardFrame.height

    if let accessory = self.inputAccessoryView {
      keyboardViewHeight += accessory.frame.height
    }
  }

    @objc func keyboardHidden(_ notification: Notification) {
    resetScrollingZone()
  }
  
  /**
   Stores the current textfield.
   
   - Parameter notification: the received notification
   */
    @objc func textFieldBecameFirstResponder(_ notification: Notification) {
    if let textfield = notification.object as? TextInput {
      currentInput = textfield
    }
  }
  
  /**
   Checks if the given input is the last one.
   
   - Parameter input: the input to compare
   */
  fileprivate func isLastInput(_ input: TextInput) -> Bool {
    if let _ = formDelegate {
      if let nextInput: TextInput = formDelegate.getNextInput(self, currentInput: currentInput) {
        return false
      }
    }
    
    return true
  }
  
  /**
   Gets the ordered inputs of the form
   
   - Return: the ordered inputs
   */
  func getOrderedInputs() -> [TextInput] {
    var inputs: [TextInput] = []
    if let _ = formDelegate {
      var inputToAdd: TextInput? = formDelegate.getFirstInput(self)
      while nil != inputToAdd {
        inputs.append(inputToAdd!)
        inputToAdd = formDelegate.getNextInput(self, currentInput: inputToAdd!)
      }
    }
    
    return inputs
  }
}

// MARK: Extensions
extension Form: TextInputDelegate {
  public func didEnterEditionMode(_ input: TextInput) {
    DispatchQueue.main.async {
      self.minimizeScrollingZone(input)
    }
  }
  
  public func didExitEditionMode(_ input: TextInput) {}
}
