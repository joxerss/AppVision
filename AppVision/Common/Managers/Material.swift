//
//  Material.swift
//  GeniusFinance
//
//  Created by Artem on 6/24/19.
//  Copyright © 2019 Artem. All rights reserved.
//

import UIKit

import MaterialComponents.MaterialDialogs
import MaterialComponents.MaterialActionSheet

/// This class contains method and static sizes for custom allerts. All allerts of this class will display in MaterialIO style. They will look and behave like in Android OS.
class Material: NSObject {
    
    /// Previous presented CustomeViewController
    static weak var popViewController : UIViewController?
    static public var popupSize: CGSize = MaterialAlertSizes.normal
    
    struct MaterialAlertSizes {
        static public let normal = CGSize(width: 340, height: 380)
        static public let smallest = CGSize(width: 340, height: 260)
        static public let smaller = CGSize(width: 340, height: 300)
        static public let small = CGSize(width: 340, height: 340)
        static public let large = CGSize(width: 340, height: 420)
        static public let larger = CGSize(width: 340, height: 460)
        static public let largest = CGSize(width: 340, height: 500)
    }
    
}

// MARK: - Snackbar
extension Material {
    
    /// Use this method for notification user about something if message isn't priority.
    ///
    /// - Parameters:
    ///   - message: Message for displaing inside of  snackBar.
    ///   - duration: How long may show snackBar.
    static func showSnackBar(message: String, duration: Double){
        let snackBar = MDCSnackbarMessage()
        snackBar.text = message
        snackBar.duration = duration
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MDCSnackbarManager.default.show(snackBar)
        }// DispatchQueue
    }
    
    static func showSnackBar(message: String, duration: Double, action: MDCSnackbarMessageAction) {
        let snackBar = MDCSnackbarMessage()
        snackBar.text = message
        snackBar.duration = duration
        snackBar.action = action
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MDCSnackbarManager.default.show(snackBar)
        }// DispatchQueue
    }
    
}

// MARK: - Alerts (Dialogs)
extension Material {
    
    /// Use this method for display custom alert popup's with actions.
    ///
    /// - Parameters:
    ///   - title: Title will be displayed in the top of view.
    ///   - message: It's your custom message.
    ///   - actions: Add array of custom MDCAlertAction for displaing in popup. This may be nil.
    ///   - shouldAddDefaultAction: If it will be true button 'Ok' will be added to end of custom buttons.
    static func showMaterialAlert(title: String?, message: String?, actions: [MDCAlertAction]? = nil, shouldAddDefaultAction: Bool = false) {
        
        if Thread.isMainThread == false {
            assertionFailure("❌ Call this functions in main thread only. \(#function)")
        }
        
        guard let rootViewController = Material.getRootViewController() else {
            return
        }
        
        let visibleController = getVisibleViewController(rootViewController)
        
        // Present a modal alert
        let alertController = MDCAlertController(title: title, message: message)
        actions?.forEach { (action) in
            alertController.addAction(action)
        }
        
        if (shouldAddDefaultAction == true) {
            let action = MDCAlertAction(title:"ok".localized()) { (action) in /*print("ok".localized())*/ }
            alertController.addAction(action)
        }
        
        visibleController?.present(alertController, animated:true, completion:nil)
    }
    
    /// Use this method for display custom UIViewController as MaterialIO alert.
    ///
    /// - Parameters:
    ///   - contentViewController: ContentViewController - it maust be your custom UIViewController for displaing inside of alert.
    ///   - animated: Animated if it will true alert will show with animation.
    ///   - authoSize: AuthoSize if it will be true your custom UIViewController will display with minimal indentation to the edges of the screen. For set cusom size to allert, set popupSize before call this method.
    static func showMaterialDialog(contentViewController: UIViewController, animated: Bool, authoSize: Bool = true) {
        
        if Thread.isMainThread == false {
            assertionFailure("❌ Call this functions in main thread only. \(#function)")
        }
        
        if(popViewController != nil){
            popViewController?.view.endEditing(false)
            popViewController?.dismiss(animated: false, completion:{
                popViewController = nil
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                popViewController = nil
                self.showMaterialDialog(contentViewController: contentViewController, animated: animated, authoSize: authoSize)
            }
        } else {
            guard let rootViewController = Material.getRootViewController() else {
                return
            }
            
            let visibleController = getVisibleViewController(rootViewController)
            visibleController?.view.endEditing(true)
            
            let dialogTransitionController: MDCDialogTransitionController = MDCDialogTransitionController()
            contentViewController.modalPresentationStyle = UIModalPresentationStyle.custom
            contentViewController.transitioningDelegate = dialogTransitionController
            
            if authoSize == false {
                contentViewController.preferredContentSize = popupSize
            }
            
            popViewController = contentViewController
            visibleController?.navigationController?.present(contentViewController, animated: animated, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                popupSize = MaterialAlertSizes.normal
            }   // DispatchQueue.main.asyncAfter
        }   // else
    }

}

// MARK: - Action Sheet
extension Material {
    
    /// Use this method for display MDCActionSheet  like in Android OS.
    ///
    /// - Parameters:
    ///   - title: Title will be displayed in the top of view.
    ///   - message: It's your custom message, it'll be  displayed under of title.
    ///   - actions: Add array of custom MDCActionSheetAction for displaing in action sheet. This parameter won't be nil.
    public static func showMaterialActionSheet(title: String?, message: String?, actions: [MDCActionSheetAction]) {
        
        if Thread.isMainThread == false {
            assertionFailure("❌ Call this functions in main thread only. \(#function)")
        }
        
        guard let rootViewController = Material.getRootViewController() else {
            return
        }
        
        let visibleController = getVisibleViewController(rootViewController)
        
        let actionSheet = MDCActionSheetController(title: title,
                                                   message: message)
        
        actions.forEach { (action) in
            actionSheet.addAction(action)
        }

        visibleController?.present(actionSheet, animated: true, completion: nil)
    }
    
}

// MARK: - Helpers
extension Material {
    static func getRootViewController() -> UIViewController? {
        var rootViewController: UIViewController?
        if #available(iOS 13.0, *) {
            // iOS 13 (or newer) Swift code
            rootViewController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        } else {
            // iOS older code
            rootViewController = UIApplication.shared.keyWindow?.rootViewController
        }
        
        return rootViewController
    }
    
    /// Use this method for hidding last displayed Material allert.
    static func hideMaterialPopUp(){
        if Thread.isMainThread == false {
            assertionFailure("❌ Call this functions in main thread only. \(#function)")
        }
        
        if popViewController == nil { return }
        popViewController?.view.endEditing(true)
        popViewController?.dismiss(animated: true, completion:{ popViewController = nil })
    }
    
    /// Use this method for getting current visable UIViewController
    ///
    /// - Parameters:
    ///   - rootViewController: RootViewController current root UIViewController.
    /// - Returns: It will return current visable UIViewController of root UIViewController.
    public static func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        
        if Thread.isMainThread == false {
            assertionFailure("❌ Call this functions in main thread only. \(#function)")
        }
        
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController
        }
        
        return rootViewController
    }

}
