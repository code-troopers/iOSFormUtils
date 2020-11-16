//
//  ValidatedTextInput.swift
//  Pods
//
//  Created by Nicolas LELOUP on 16/09/2016.
//
//

import Foundation

/**
 Validation kinds enumeration
 
 - NoValidation: Default one, easy understandable.
 - NotBlank: For required fields
 - Email: For Email format fields
 - ZipCode: For french zipcodes
 - Phone: For french phone numbers
 - Date: For basic dd/mm/yyy format
 */
public enum ValidatedTextInputType: String {
  case NoValidation, NotBlank, Email, ZipCode, Phone, Date
}

// MARK: Protocols
/// Validate input protocol
public protocol ValidatedTextInput {
  /**
   Applies validation on the input
   
   - Return: true if valid, false if not.
   */
  func validateFormat() -> Bool
}

/// Delegate protocol for validated form
public protocol ValidatedTextInputDelegate {
  /**
   To update the input displaying for error mode.
   
   - Parameter input: The input
   - Parameter errorType: The error description
   */
  func didEnterErrorMode(_ input: ValidatedTextInput, errorType: String)
  
  /**
   To update the input without the error mode.
   
   - Parameter input: The input
   */
  func didExitErrorMode(_ input: ValidatedTextInput)
}

/// Data Source protocol for validated form
public protocol ValidatedTextInputDataSource {
  /**
   Gives a validation type for an input.
   
   - Parameter input: The input
   */
  func validationTypeForInput(_ input: ValidatedTextInput) -> ValidatedTextInputType
}

// MARK: Extensions
extension TextInput: ValidatedTextInput {
  public func validateFormat() -> Bool {
    if let _ = validationDataSource {
      switch validationDataSource.validationTypeForInput(self) {
      case .NotBlank :
        if (0 < self.text!.count) {
          return true
        }
      case .Email :
        let emailValidator: NSPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        if (emailValidator.evaluate(with: self.text)) {
          return true;
        }
      case .ZipCode :
        let zipCodeValidator: NSPredicate = NSPredicate(format: "SELF MATCHES %@", "((0[1-9])|([1-8][0-9])|(9[0-8])|(2A)|(2B))[0-9]{3}")
        if (zipCodeValidator.evaluate(with: self.text)) {
          return true;
        }
      case .Date :
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        if let _ = dateFormatter.date(from: self.text!) {
          return true
        }
      case .Phone :
        let phoneValidator: NSPredicate = NSPredicate(format: "SELF MATCHES %@", "(0[1-9]([-. ]?[0-9]{2}){4})")
        if (phoneValidator.evaluate(with: self.text)) {
          return true;
        }
      case .NoValidation :
        return true
      default :
        return true
      }
      
      if let _ = validationDelegate {
        validationDelegate.didEnterErrorMode(self, errorType: validationDataSource.validationTypeForInput(self).rawValue)
      }
      
      return false
    }
    
    return true
  }
}
