//
//  UIView+Material.swift
//  GeniusFinance
//
//  Created by Artem Syritsa on 17.07.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit
import MaterialComponents.MDCActivityIndicator

extension UIView {
    
    public typealias ActivityProgressHandler = ((_ sendedSize: Float, _ totalSize: Float) -> (Void))
    
    // MARK: - Associated Keys
    private struct AssociatedKeys {
        static var kActivityIndicatior = "key_activityIndicatior"
        static var kActivityBlureEffect = "key_activityBlureEffect"
        static var kActivityProgressHandler = "key_activityProgressHandler"
    }
    
    // MARK: - Associated Properties
    
    private var mdcActivityIndicator: MDCActivityIndicator {
        get {
            guard let view = objc_getAssociatedObject(self, &AssociatedKeys.kActivityIndicatior) as? MDCActivityIndicator else {
                return initMDCActivityIndicator()
            }
            
            return view
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.kActivityIndicatior, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var mdcActivityBlureEffect: UIVisualEffectView {
        get {
            guard let effect = objc_getAssociatedObject(self, &AssociatedKeys.kActivityBlureEffect) as? UIVisualEffectView else {
                return initActivityBlureEffect()
            }
            
            return effect
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.kActivityBlureEffect, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var mdcActivityProgressHandler: ActivityProgressHandler {
        get {
            guard let effect = objc_getAssociatedObject(self, &AssociatedKeys.kActivityProgressHandler) as? ActivityProgressHandler else {
                return initActivityProgressHandler()
            }
            
            return effect
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.kActivityProgressHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // MARK: - Init's
    
    private func initMDCActivityIndicator() -> MDCActivityIndicator {
        let indicatorRadius = self.frame.size.width <= self.frame.size.height ? self.frame.size.width / 18 : self.frame.size.height / 18
        let indicator = MDCActivityIndicator()
        indicator.sizeToFit()
        indicator.radius =  indicatorRadius > 12.0 ? indicatorRadius : 12.0
        indicator.progress = 0.0
        indicator.indicatorMode = .indeterminate
        
        mdcActivityIndicator = indicator
        return indicator
    }
    
    private func initActivityBlureEffect() -> UIVisualEffectView {
        var blureEffect: UIBlurEffect
        if #available(iOS 13.0, *) {
            blureEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        } else {
            // Fallback on earlier versions
            blureEffect = UIBlurEffect(style: .regular)
        }
        let blurredEffectView = UIVisualEffectView(effect: blureEffect)
        blurredEffectView.frame = self.bounds
        blurredEffectView.clipsToBounds = true
        
        mdcActivityBlureEffect = blurredEffectView
        setupConstraints()
        blurredEffectView.isHidden = true
        
        return blurredEffectView
    }
    
    private func setupConstraints() -> Void {
        mdcActivityBlureEffect.contentView.addSubview(mdcActivityIndicator)
        self.addSubview(mdcActivityBlureEffect)
        
        mdcActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        mdcActivityBlureEffect.translatesAutoresizingMaskIntoConstraints = false
        
        mdcActivityBlureEffect.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        mdcActivityBlureEffect.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        mdcActivityBlureEffect.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mdcActivityBlureEffect.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        
        mdcActivityIndicator.centerXAnchor.constraint(equalTo: mdcActivityBlureEffect.centerXAnchor).isActive = true
        mdcActivityIndicator.centerYAnchor.constraint(equalTo: mdcActivityBlureEffect.centerYAnchor).isActive = true

        mdcActivityIndicator.topAnchor.constraint(greaterThanOrEqualTo: mdcActivityBlureEffect.topAnchor).isActive = true
        mdcActivityIndicator.leftAnchor.constraint(greaterThanOrEqualTo: mdcActivityBlureEffect.leftAnchor).isActive = true

        self.layoutIfNeeded()
    }
    
    private func initActivityProgressHandler() -> ActivityProgressHandler {
        let progressHandler: ActivityProgressHandler = { [weak self] sendedSize, totalSize in
            
            if totalSize < sendedSize {
                self?.resetLoader()
                return
            }
            
            if self?.mdcActivityBlureEffect.isHidden == true {
                self?.showMDCActivity()
            }
            
            self?.mdcActivityIndicator.indicatorMode = .determinate
            self?.mdcActivityIndicator.startAnimating()
            
            
            let progress = sendedSize / totalSize
            self?.mdcActivityIndicator.progress = progress
            
            print("👩🏼‍💻⤵️ sendedSize :\(sendedSize) totalSize :\(totalSize)")
            
            if sendedSize >= totalSize {
                self?.resetLoader()
            }
        }
        
        return progressHandler
    }
    
    private func resetLoader() {
        mdcActivityIndicator.indicatorMode = .indeterminate
        mdcActivityIndicator.progress = 0.0
    }
    
    // MARK: - Actions
    
    func showMDCActivity() -> Void {
        mdcActivityBlureEffect.isHidden = false
        mdcActivityIndicator.startAnimating()
        
        self.bringSubviewToFront(mdcActivityBlureEffect)
    }
    
    func hideMDCActivity() -> Void {
        mdcActivityBlureEffect.isHidden = true
        mdcActivityIndicator.stopAnimating()
    }
    
}
