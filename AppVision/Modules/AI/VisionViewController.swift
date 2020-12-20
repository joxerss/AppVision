//
//  VisionViewController.swift
//  AppVision
//
//  Created by Artem Syritsa on 26.11.2020.
//

import UIKit
import MaterialComponents
import Vision

class VisionViewController: BaseController {
    
    @IBOutlet weak var titleReceipt: UILabel!
    @IBOutlet weak var scanButton: MDCButton!
    @IBOutlet weak var scanTextButton: MDCButton!
    @IBOutlet weak var scanOtherButton: MDCButton!
    @IBOutlet weak var textContent: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [UIImage] = [UIImage]()
    
    lazy var visionManager: VisionManager = {
        return .init(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareViews() {
        super.prepareViews()
        //collectionView.register(VisionCollectionViewCell.self, forCellWithReuseIdentifier: "VisionCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        configCollectionViewLayout()
    }
    
    override func localize() {
        super.localize()
        
        scanButton.setTitle("scan.images".localized(), for: .normal)
        scanTextButton.setTitle("scan.receipt_content".localized(), for: .normal)
        scanOtherButton.setTitle("scan.other".localized(), for: .normal)
    }
    
    @IBAction func scanAction(_ sender: Any) {
        visionManager.pickContent(with: .receiptsImages)
    }
    
    @IBAction func scanTextAction(_ sender: Any) {
        visionManager.pickContent(with: .receipts)
    }
    
    @IBAction func scanOtherAction(_ sender: Any) {
        visionManager.pickContent(with: .other)
    }
    
}

extension VisionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate func configCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: self.collectionView.frame.size.width * 0.95, height: self.collectionView.frame.size.height - 16)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VisionCollectionViewCell", for: indexPath) as! VisionCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        cell.backgroundColor = .lightGray
        return cell
    }
    
}

extension VisionViewController: RecognizedContentDataSource, VisionManagerDelegate {
    
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        var transcript = ""
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            transcript += candidate.string
            transcript += "\n"
        }
        DispatchQueue.main.async {
            self.textContent.isHidden = false
            self.collectionView.isHidden = true
            self.textContent.text = transcript
        }

        /*CGFloat fixedWidth = textView.frame.size.width;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        multiplelineTextField.frame = newFrame;*/
    }
    
    func addRecognizedImages(recognizedImages: [UIImage]) {
        images = recognizedImages
        DispatchQueue.main.async {
            self.textContent.isHidden = true
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
        
    }
    
    func presentVisionController(viewContoller: UIViewController, animated: Bool) {
        self.present(viewContoller, animated: animated, completion: nil)
    }
    
    func didFinishVisionFlow() {
        titleReceipt.text = "\(#function)"
    }
    
    func didFinishVisionFlow(with error: Error?) {
        titleReceipt.text = "\(error?.localizedDescription ?? "Something went wrong.")"
    }
    
    func didCancelVisionFlow() {
        titleReceipt.text = "\(#function)"
    }
    
}
