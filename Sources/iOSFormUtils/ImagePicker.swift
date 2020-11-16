//
//  ImagePicker.swift
//  Pods
//
//  Created by Nicolas LELOUP on 01/09/2017.
//
//

import Foundation
import UIKit

public protocol ImagePickerDataSource {
  func controllerForDisplaying() -> UIViewController
}

public protocol ImagePickerDelegate {
  func imagePicker(_ picker: ImagePicker, selectedImage image: UIImage)
  func imagePickerReturnsNoImages(_ picker: ImagePicker)
}

public class ImagePicker: UIButton {
  public var delegate: ImagePickerDelegate!
  public var dataSource: ImagePickerDataSource!
  public var selectedImage: UIImage!

  let imagePicker: UIImagePickerController = UIImagePickerController()
  var actionSheet: UIAlertController!

  public var importButtonTitle = "Import picture"
  public var captureButtonTitle = "Take picture"
  public var cancelButtonTitle = "Cancel"

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    imagePicker.delegate = self
  }

  public func reloadData() {
    actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (_) in
    }
    actionSheet.addAction(cancelAction)
    let importAction = UIAlertAction(title: importButtonTitle, style: .default) { (_) in
      self.importPhoto()
    }
    actionSheet.addAction(importAction)
    let captureAction = UIAlertAction(title: captureButtonTitle, style: .default) { (_) in
      self.capturePhoto()
    }
    actionSheet.addAction(captureAction)
    actionSheet.popoverPresentationController?.delegate = self

    self.addTarget(self, action: #selector(ImagePicker.selfTouched(_:)), for: .touchUpInside)
  }

  private func importPhoto() {
    imagePicker.sourceType = .photoLibrary
    presentImagePicker()
  }

  private func capturePhoto() {
    imagePicker.sourceType = .camera
    presentImagePicker()
  }

  private func presentImagePicker() {
    if let _ = dataSource {
      dataSource.controllerForDisplaying().present(imagePicker, animated: true)
    } else {
      print("iOSFormUtils/ImagePicker: No data source controller set for image picker displaying.")
    }
  }

  @objc func selfTouched(_ sender: Any) {
    if let _ = dataSource {
      dataSource.controllerForDisplaying().present(actionSheet, animated: true)
    } else {
      print("iOSFormUtils/ImagePicker: No data source controller set for action sheet displaying.")
    }
  }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      if let _ = delegate {
        self.selectedImage = pickedImage
        delegate.imagePicker(self, selectedImage: pickedImage)
      } else {
        print("iOSFormUtils/ImagePicker: No delegate set for picked image using.")
      }
    } else {
      if let _ = delegate {
        self.selectedImage = nil
        delegate.imagePickerReturnsNoImages(self)
      } else {
        print("iOSFormUtils/ImagePicker: No delegate set for image picker.")
      }
    }
    imagePicker.dismiss(animated: true, completion: nil)
  }

  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
  }
}

extension ImagePicker: UIPopoverPresentationControllerDelegate {
  public func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
    if let _ = dataSource {
      popoverPresentationController.sourceView = self
      popoverPresentationController.sourceRect = self.bounds
    }
  }
}
