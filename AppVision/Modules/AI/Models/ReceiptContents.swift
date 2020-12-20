//
//  ReceiptContents.swift
//  Costless
//
//  Created by Artem on 25.11.2020.
//  Copyright © 2020 Sannacode. All rights reserved.
//

import Vision

typealias ReceiptContentField = (name: String, value: String)

// The information to fetch a scanned receipt.
struct ReceiptContents {
    // Use this height to differentiate between big labels and small labels in a receipt.
    static let textHeightThreshold: CGFloat = 0.025
    
    var name: String?
    var items: [ReceiptContentField] = [ReceiptContentField]()
}
