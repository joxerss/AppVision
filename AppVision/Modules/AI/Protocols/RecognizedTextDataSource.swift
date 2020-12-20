//
//  RecognizedTextDataSource.swift
//  Costless
//
//  Created by Artem on 25.11.2020.
//  Copyright © 2020 Sannacode. All rights reserved.
//

import UIKit
import Vision

@available(iOS 13.0, *)
/// Override this protocol in ViewController or DataSource of it to handle founded text.
protocol RecognizedContentDataSource: AnyObject {
    /// Override custome content mapping in this method.
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) -> Void
    
    /// This method will  contain picked images.
    func addRecognizedImages(recognizedImages: [UIImage]) -> Void
}
