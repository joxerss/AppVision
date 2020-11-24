//
//  MainCoordinator.swift
//  MapPoints
//
//  Created by Artem on 27.12.2019.
//  Copyright © 2019 Artem. All rights reserved.
//

import UIKit

extension UIViewController {
    @available(iOS 13.0, *)
    static func initContoller(_ storyboard: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard.init(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: identifier)
        
        return controller
    }
}

class MainCoordinator: NSObject {
    
    // MARK: - Properties
    
    static let shared: MainCoordinator = MainCoordinator()
    var rootController: UIViewController?
    var visableController: UIViewController {
        get {
            return Material.getRootViewController()!//Material.getVisibleViewController(MainCoordinator.shared.rootController) ?? MainCoordinator.shared.rootController
        }
    }
    
    // MARK: - Life cycle
    
    private override init() {
        super.init()
    }
    
    // MARK: - Global actions
    
    func setRootViewController(_ viewController: UIViewController, complition: (()->())? ) -> Void {
        var window: UIWindow? = nil
        if #available(iOS 13.0, *) {
            // iOS 13 (or newer) Swift code
            window = UIApplication.shared.windows.first
        } else {
            // iOS older code
            window = UIApplication.shared.keyWindow
        }
        
        guard let curWindow = window else {
            fatalError("🚀❌ window can't be nil!!")
        }
        
        viewController.modalPresentationStyle = .fullScreen
        curWindow.rootViewController = viewController
        curWindow.makeKeyAndVisible()
        
        rootController = viewController
        
        UIView.transition(with: curWindow, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: { _ in
            if let complition = complition {
                complition()
            }
        })
    }
    
    // MARK: - Public present / push controllers
    
    public func presentController(_ controller: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        
        visableController.present(controller, animated: animated, completion: completion)
    }
    
    public func pushViewController(_ controller: UIViewController, animated: Bool = true) {
        
        if let navigation = visableController as? UINavigationController {
            navigation.pushViewController(controller, animated: animated)
        } else {
            visableController.navigationController?.pushViewController(controller, animated: animated)
        }
    }
    
}
