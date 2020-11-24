//
//  String+Extensions.swift
//  MapPoints
//
//  Created by Artem on 27.12.2019.
//  Copyright © 2019 Artem. All rights reserved.
//

import UIKit
import CryptoKit
import CommonCrypto

fileprivate let lproj = "lproj" // localized file extension

// MARK: String extension
extension String {
    
    // MARK: - Localization
    
    /// used to localize string from code
    public func localized(in language: String? = nil) -> String {
        //let languages = Bundle.main.localizations
        guard let bundle = String.bundleForLanguage(language) else {
            return NSLocalizedString(self, comment: "")
        }
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle, comment: "")
    }
    
    public static var bundleForLanguage: (_ language: String?) -> Bundle? = { language in
        if let path = Bundle.main.path(forResource: language ?? Locale.current.languageCode, ofType: lproj),
            let bundle = Bundle(path: path) {
            return bundle
        }
        return nil
    }
    
    public func attributedMiddlePlaceholder(_ color: UIColor) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attrStr = NSAttributedString(string: self.localized(),
                                         attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.paragraphStyle: paragraph])
        return attrStr;
    }
    
    public func attributedString(_ color: UIColor) -> NSAttributedString {
        let attrStr = NSAttributedString(string: self.localized(),
                                         attributes: [NSAttributedString.Key.foregroundColor: color])
        return attrStr;
    }
    
    // MARK: - Validations
    
    func isValidEmail() -> Bool {
        let emailRegEx = #"^([\w\.]+)\@([a-zA-Z0-9]+)\.([a-zA-Z]{2,4})$"#
        let regexp = try? NSRegularExpression(pattern: emailRegEx, options: [.caseInsensitive])
        return regexp?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
    }
    
    func isValidPassword() -> Bool {
        let passwordRegex = #"^[a-zA-Z\d\@\!]{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    var isValidPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    // MARK: - Ranges of word in string
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale)
        {
            ranges.append(range)
        }
        return ranges
    }
    
}
