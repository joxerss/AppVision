//
//  ReceiptContents.swift
//  AppVision
//
//  Created by Artem Syritsa on 24.11.2020.
//

import UIKit
import Vision

typealias ReceiptContentField = (name: String, value: String)

protocol RecognizedTextDataSource: AnyObject {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
}

// The information to fetch from a scanned receipt.
struct ReceiptContents {

    // Use this height value to differentiate between big labels and small labels in a receipt.
    static let textHeightThreshold: CGFloat = 0.025
    
    var name: String?
    var items = [ReceiptContentField]()
}
