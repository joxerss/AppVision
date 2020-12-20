//
//  VisionManager.swift
//  Costless
//
//  Created by Artem on 25.11.2020.
//  Copyright © 2020 Sannacode. All rights reserved.
//

import Vision
import VisionKit
import MobileCoreServices
import MaterialComponents

enum ScanMode: Int, CaseIterable {
    
    // Text from scanned image in ReceiptContents container.
    case receipts
    // Scanned or picked images, this case doesn't use Vision Framework for fetch content.
    case receiptsImages
    
    //case businessCards
    // Scanned content like [VNRecognizedTextObservation].
    case other
}

@available(iOS 13.0, *)
protocol VisionManagerDelegate: AnyObject {
    
    /// This method will be called if **VisionManager** need to present some ViewController.
    func presentVisionController(viewContoller: UIViewController, animated: Bool)
    
    /// It will be called if **VisionManager** has been dismissed programmatically.
    ///
    /// **RecognizedContentDataSource** will be called before with vision result.
    func didFinishVisionFlow()
    
    /// This method will be called if something returns with error, force abort **Vision flow**.
    func didFinishVisionFlow(with error: Error?)
    
    /// This method will be called if user abort **Vision flow**.
    func didCancelVisionFlow()
}

@available(iOS 13.0, *)
class VisionManager: NSObject {
    
    typealias VisionDataSourceDelegate = (VisionManagerDelegate & RecognizedContentDataSource)
    
    // MARK: - Properties
    
    private(set) var scanMode: ScanMode = .receipts
    fileprivate var textRecognitionRequest = VNRecognizeTextRequest()
    
    private(set) var contents: ReceiptContents = ReceiptContents()
    
    // MARK: Delegates & Datasources
    
    fileprivate var visionDelegate: VisionDataSourceDelegate?
    
    // MARK: - Life cycle
    
    init(delegate: VisionDataSourceDelegate) {
        super.init()
        self.visionDelegate = delegate
        configurateVision()
    }
    
    // MARK: - Configurations.
    
    private func configurateVision() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { [weak self] (request, error) in
            guard let `visionDelegate` = self?.visionDelegate else {
                print("🔨 visionDelegate is not RecognizedTextDataSource")
                return
            }
            
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    visionDelegate.addRecognizedText(recognizedText: requestResults)
                }
            } else {
                visionDelegate.addRecognizedText(recognizedText: [])
            }
        })
        // This doesn't require OCR on a live camera feed, select accurate for more accurate results.
        textRecognitionRequest.recognitionLevel = .accurate
        //textRecognitionRequest.recognitionLanguages = ["en", "ru"]
        //textRecognitionRequest.customWords = ["Лимон", "Мандарин"]
        textRecognitionRequest.usesLanguageCorrection = false
    }
    
    
    // MARK: - Public methods.
    
    func pickContent(with scanMode: ScanMode) {
        self.scanMode = scanMode
        
        var actions: [MDCActionSheetAction] = [MDCActionSheetAction]()
        
        let cameraAction: MDCActionSheetAction = MDCActionSheetAction(title: "source.camera".localized(), image: #imageLiteral(resourceName: "ic_camera_add") , handler: { [weak self] (_) in
            self?.openVisionController()
        })
        
        let galleryAction: MDCActionSheetAction = MDCActionSheetAction(title: "source.gallery".localized(), image: #imageLiteral(resourceName: "ic_gallery_add"), handler: { [weak self] (_) in
            self?.openImagePicker()
        })
        
        let cancelAction: MDCActionSheetAction = MDCActionSheetAction(title: "cancel".localized(), image: #imageLiteral(resourceName: "close_icon"), handler: { _ in })
        
        actions.append(cameraAction)
        actions.append(galleryAction)
        actions.append(cancelAction)
        
        DispatchQueue.main.async {
            Material.showMaterialActionSheet(title: "vision_manager.source_title".localized(), message: "vision_manager.source_message".localized(), actions: actions)
        }
    }
    
    // MARK: - Private methods.
    
    /// Fetch content from **found image** by **Vision Framework**.
    /// - Parameter image: which was scanned or gotten from library.
    private func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("🔨 Failed to get cgimage from input image")
            return
        }
        
        switch self.scanMode {
        case .receiptsImages:
            assertionFailure("🔧 VisionManager imposible case.")
            break
        default:
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Open
    
    private func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.modalPresentationStyle = .fullScreen
        visionDelegate?.presentVisionController(viewContoller: imagePicker, animated: true)
    }
    
    private func openVisionController() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        visionDelegate?.presentVisionController(viewContoller: documentCameraViewController, animated: true)
    }
    
}

// MARK: -
@available(iOS 13.0, *)
extension VisionManager: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        visionDelegate?.didFinishVisionFlow(with: error)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        visionDelegate?.didCancelVisionFlow()
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) {
            DispatchQueue.global(qos: .userInitiated).async {
                switch self.scanMode {
                case .receiptsImages:
                    var images: [UIImage] = [UIImage]()
                    for pageNumber in 0 ..< scan.pageCount {
                        images.append( scan.imageOfPage(at: pageNumber) )
                    }
                    self.visionDelegate?.addRecognizedImages(recognizedImages: images)
                    break
                default:
                    for pageNumber in 0 ..< scan.pageCount {
                        let image = scan.imageOfPage(at: pageNumber)
                        self.processImage(image: image)
                    }
                }
            }
        }
    }
    
}

// MARK: -
@available(iOS 13.0, *)
extension VisionManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            picker.dismiss(animated: true) { [weak self] in
                switch self?.scanMode {
                case .receiptsImages:
                    self?.visionDelegate?.addRecognizedImages(recognizedImages: [image])
                    break
                default:
                    self?.processImage(image: image)
                }
            }
        } else {
            picker.dismiss(animated: true, completion: nil)
            visionDelegate?.didFinishVisionFlow(with: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        visionDelegate?.didCancelVisionFlow()
    }
    
}
