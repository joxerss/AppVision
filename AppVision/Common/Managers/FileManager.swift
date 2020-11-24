//
//  FileManager.swift
//  GeniusFinance
//
//  Created by Artem Syritsa on 18.10.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialActionSheet
import Photos
import PhotosUI

class FileManager: NSObject {
    
    // MARK: - Properties
    
    private lazy var picker: UIImagePickerController = {
        let controller = UIImagePickerController()
        controller.delegate = self
        return controller
    }()
    
    var pickImageCallback : ((UIImage?) -> ())?
    
    // MARK: - Lifecycle
    
    override init(){
        super.init()
    }
    
    // MARK: - Public functions
    
    func pickImage(_ callback: @escaping ((UIImage?) -> ())) {
        pickImageCallback = callback
        
        var actions: Array<MDCActionSheetAction> = Array()
        let cameraAction: MDCActionSheetAction = MDCActionSheetAction(title: "source.camera".localized(), image: #imageLiteral(resourceName: "ic_camera_add") , handler: { [weak self] (_) in
            self?.openCamera()
        })
        
        let galleryAction: MDCActionSheetAction = MDCActionSheetAction(title: "source.gallery".localized(), image: #imageLiteral(resourceName: "ic_gallery_add"), handler: { [weak self] (_) in
            self?.openGallery()
        })
        
        let cancelAction: MDCActionSheetAction = MDCActionSheetAction(title: "cancel".localized(), image: #imageLiteral(resourceName: "close_icon"), handler: { _ in })
        
        actions.append(cameraAction)
        actions.append(galleryAction)
        actions.append(cancelAction)
        
        Material.showMaterialActionSheet(title: "source.choose_source".localized(), message: nil, actions: actions)
    }
    
    func openCamera() {
        if (UIImagePickerController .isSourceTypeAvailable(.camera)) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
                if response == true {
                    DispatchQueue.main.async {
                        //access granted
                        guard let `picker` = self?.picker else {
                            self?.pickImageCallback?(nil)
                            return
                        }
                        
                        picker.sourceType = .camera
                        MainCoordinator.shared.presentController(picker, animated: true, completion: nil)
                    }
                } else {
                    Material.showSnackBar(message: "source.camera_no_permissions".localized(), duration: 5.0)
                }
            }
            
        } else {
            Material.showSnackBar(message: "source.camera_is_not_available".localized(), duration: 5.0)
        }
    }
    
    func openGallery() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            switch status {
            case .authorized, .limited:
                
                if #available(iOS 14, *) {
                    self?.presentPicker()
                } else {
                    DispatchQueue.main.async {
                        // Fallback on earlier versions
                        guard let `picker` = self?.picker else {
                            self?.pickImageCallback?(nil)
                            return
                        }
                
                        picker.sourceType = .photoLibrary
                        MainCoordinator.shared.presentController(picker, animated: true, completion: nil)
                    }
                }
                
            default:
                Material.showSnackBar(message: "source.gallery_no_permissions".localized(), duration: 5.0)
            }
        }
        
    }
    
}

// MARK: -
extension FileManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        pickImageCallback?(image)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
    }
    
}

// MARK: - @available(iOS 14, *)
@available(iOS 14, *)
extension FileManager: PHPickerViewControllerDelegate {
    
    @available(iOS 14, *)
    func presentPicker() {
        
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        DispatchQueue.main.async {
            MainCoordinator.shared.presentController(picker)
        }
        
    }
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: .none)
        
        // Do something with the fetch result if you have Photos Library access
        guard let asset = fetchResult.firstObject else {
            pickImageCallback?(nil)
            return
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .default, options: .none) { [weak self] image, _ in
            self?.pickImageCallback?(image)
        }
        
    }
}
