//
//  BaseNavigationController.swift
//  Player
//
//  Created by Artem Syritsa on 21.03.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupAppearances()
    }
    
    /// This method will call when System Color Scheme did changed.
    /// It will call by system **automatically**.
    /// - Parameter previousTraitCollection: System UITraitCollection
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

//        guard UIApplication.shared.applicationState == .inactive else {
//            return
//        }

        setupAppearances()
    }
    
    @objc func setupAppearances() -> Void {
        //UINavigationBar.appearance().barTintColor = .clear
        //UINavigationBar.appearance().tintColor = .red
        //UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)]
        
        //self.makeNavigationTransparent()
        
    }
}
