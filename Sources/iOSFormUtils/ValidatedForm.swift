//
//  ValidatedForm.swift
//  application
//
//  Created by Nicolas LELOUP on 09/09/2015.
//  Copyright (c) 2015 Nicolas LELOUP - Buzznative. All rights reserved.
//

import Foundation

// MARK: Class
/// Form class able to validates its fields
open class ValidatedForm: Form {
  
  // MARK: Public own methods
  
  /**
   Checks if all fields are valid
   
   - Return: validation result
   */
  open func validate() -> Bool {
    for input in getOrderedInputs() {
      if (!input.validateFormat()) {
        return false
      }
    }
    
    return true
  }
}
