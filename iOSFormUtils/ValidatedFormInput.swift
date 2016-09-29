//
//  ValidatedFormInput.swift
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
public enum ValidatedFormInputType: String {
  case NoValidation, NotBlank, Email, ZipCode, Phone, Date
}

// MARK: Protocols
/// Validate input protocol
public protocol ValidatedFormInput {
  /**
   Applies validation on the input
   
   - Return: true if valid, false if not.
   */
  func validateFormat() -> Bool
}

/// Delegate protocol for validated form
public protocol ValidatedFormInputDelegate {
  /**
   To update the input displaying for error mode.
   
   - Parameter input: The input
   - Parameter errorType: The error description
   */
  func didEnterErrorMode(input: ValidatedFormInput, errorType: String)
  
  /**
   To update the input without the error mode.
   
   - Parameter input: The input
   */
  func didExitErrorMode(input: ValidatedFormInput)
}

/// Data Source protocol for validated form
public protocol ValidatedFormInputDataSource {
  /**
   Gives a validation type for an input.
   
   - Parameter input: The input
   */
  func validationTypeForInput(input: ValidatedFormInput) -> ValidatedFormInputType
}

// MARK: Extensions
extension FormInput: ValidatedFormInput {
  public func validateFormat() -> Bool {
    if let dataSource = validationDataSource {
      switch validationDataSource.validationTypeForInput(self) {
      case .NotBlank :
        if (0 < self.text!.characters.count) {
          return true
        }
      case .Email :
        let emailValidator: NSPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        if (emailValidator.evaluateWithObject(self.text)) {
          return true;
        }
      case .ZipCode :
        let zipCodeValidator: NSPredicate = NSPredicate(format: "SELF MATCHES %@", "((0[1-9])|([1-8][0-9])|(9[0-8])|(2A)|(2B))[0-9]{3}")
        if (zipCodeValidator.evaluateWithObject(self.text)) {
          return true;
        }
      case .Date :
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        if let _ = dateFormatter.dateFromString(self.text!) {
          return true
        }
      case .Phone :
        let phoneValidator: NSPredicate = NSPredicate(format: "SELF MATCHES %@", "(0[1-9]([-. ]?[0-9]{2}){4})")
        if (phoneValidator.evaluateWithObject(self.text)) {
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