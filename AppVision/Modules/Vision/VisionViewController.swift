//
//  VisionViewController.swift
//  AppVision
//
//  Created by Artem Syritsa on 24.11.2020.
//

import UIKit
import MaterialComponents
import Vision
import VisionKit

class VisionViewController: BaseController {
    
    // MARK: - Properties
    
    var scanMode: ScanMode = .receipts
    var resultsViewController: (UIViewController & RecognizedTextDataSource)?
    var textRecognitionRequest = VNRecognizeTextRequest()
    
    var contents: ReceiptContents = ReceiptContents()
    
    lazy var fileManager: FileManager = {
        let manager = FileManager()
        
        manager.pickImageCallback = { [weak self] (image) in
            guard let `image` = image else {
                return
            }
            self?.processImage(image: image)
        }
        
        return manager
    }()
    
    // MARK: - Life cycle
    
    @IBOutlet weak var titleReciept: UILabel!
    @IBOutlet weak var detectButton: MDCButton!
    @IBOutlet weak var multipleLineTextField: MDCMultilineTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func localize() {
        super.localize()
        titleReciept.text = "receipt_scanner".localized()
        detectButton.setTitle("action.detect".localized(), for: .normal)
    }
    
    // MARK: - Override
    
    override func prepareViews() {
        super.prepareViews()
        multipleLineTextField.textView?.isEditable = false
        configurateVision()
    }
    
    // MARK: - Actions
    
    @IBAction func detectAction(_ sender: Any) {
        self.scanMode = .receipts
        self.resultsViewController = self
        
        var actions: Array<MDCActionSheetAction> = Array()
        let galleryAction: MDCActionSheetAction = MDCActionSheetAction(title: "source.gallery".localized(), image: #imageLiteral(resourceName: "ic_gallery_add"), handler: { [weak self] (_) in
            self?.fileManager.openGallery()
        })
        
        let realtimeAction: MDCActionSheetAction = MDCActionSheetAction(title: "source.realtime_scaner".localized(), image: #imageLiteral(resourceName: "ic_camera_add") , handler: { [weak self] (_) in
            self?.openRealtimeScaner()
        })
        
        let cancelAction: MDCActionSheetAction = MDCActionSheetAction(title: "cancel".localized(), image: #imageLiteral(resourceName: "close_icon"), handler: { _ in })
        
        actions.append(galleryAction)
        actions.append(realtimeAction)
        actions.append(cancelAction)
        
        Material.showMaterialActionSheet(title: "source.choose_source".localized(), message: nil, actions: actions)
    }
    
    
    // MARK: - Vison Request Handler
    
    func configurateVision() {
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { [weak self] (request, error) in
            guard let resultsViewController = self?.resultsViewController else {
                print("🔨 resultsViewController is not set")
                return
            }
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    print("🔨 Founded data \(requestResults.count)")
                    DispatchQueue.main.async {
                        resultsViewController.addRecognizedText(recognizedText: requestResults)
                    }
                }
            }
        })
        // This doesn't require OCR on a live camera feed, select accurate for more accurate results.
        textRecognitionRequest.recognitionLevel = .accurate
        //textRecognitionRequest.recognitionLanguages = ["en", "ru"]
        //textRecognitionRequest.customWords = ["Лимон", "Мандарин"]
        textRecognitionRequest.usesLanguageCorrection = false
    }
    
    func openRealtimeScaner() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("🔨 Failed to get cgimage from input image")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
    
}

// MARK: -
extension VisionViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        view.showMDCActivity()
        controller.dismiss(animated: true) {
            DispatchQueue.global(qos: .userInitiated).async {
                for pageNumber in 0 ..< scan.pageCount {
                    let image = scan.imageOfPage(at: pageNumber)
                    self.processImage(image: image)
                }
                DispatchQueue.main.async {
                    self.view.hideMDCActivity()
                }
            }
        }
        
    }
}

// MARK: - RecognizedTextDataSource
extension VisionViewController: RecognizedTextDataSource {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        // Create a full transcript to run analysis on.
        /*var currLabel: String?
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            let isLarge = (observation.boundingBox.height > ReceiptContents.textHeightThreshold)
            var text = candidate.string
            // The value might be preceded by a qualifier (e.g A small '3x' preceding 'Additional shot'.)
            var valueQualifier: VNRecognizedTextObservation?
            
            //contents.items.append(("\(text)", " some value"))
            if isLarge {
                if let label = currLabel {
                    if let qualifier = valueQualifier {
                        if abs(qualifier.boundingBox.minY - observation.boundingBox.minY) < 0.01 {
                            // The qualifier's baseline is within 1% of the current observation's baseline, it must belong to the current value.
                            let qualifierCandidate = qualifier.topCandidates(1)[0]
                            text = qualifierCandidate.string + " " + text
                        }
                        valueQualifier = nil
                    }
                    contents.items.append((label, text))
                    currLabel = nil
                } else if contents.name == nil && observation.boundingBox.minX < 0.5 && text.count >= 2 {
                    // Name is located on the top-left of the receipt.
                    contents.name = text
                }
            } else {
                if text.starts(with: "#") {
                    // Order number is the only thing that starts with #.
                    contents.items.append(("Order", text))
                } else if currLabel == nil {
                    currLabel = text
                } else {
                    do {
                        // Create an NSDataDetector to detect whether there is a date in the string.
                        let types: NSTextCheckingResult.CheckingType = [.date]
                        let detector = try NSDataDetector(types: types.rawValue)
                        let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                        if !matches.isEmpty {
                            contents.items.append(("Date", text))
                        } else {
                            // This observation is potentially a qualifier.
                            valueQualifier = observation
                        }
                    } catch {
                        print(error)
                    }
                    
                }
            }
        }*/
        
        /*titleReciept.text = nil
        multipleLineTextField.textView?.text = nil
        
        print("🔨 Scanned Receipt name: \(contents.name ?? "name not found")")
        titleReciept.text = "🔨 Scanned Receipt name: \(contents.name ?? "name not found")"
        for item in contents.items {
            print("🔨 Item name: \(item.name) 🗂 value \(item.value)")
            multipleLineTextField.textView?.text = "\(multipleLineTextField.textView?.text ?? "")\n🔨 Item name: \(item.name) 🗂 value \(item.value)"
        }*/
        
        var transcript = ""
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            transcript += candidate.string
            transcript += "\n"
        }
        multipleLineTextField.text = transcript
    }
}
