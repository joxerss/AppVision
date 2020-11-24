//
//  UIViewController+KeyBoard.swift
//  TasksManager
//
//  Created by Artem Syritsa on 04.02.2020.
//  Copyright © 2020 Artem Syritsa. All rights reserved.
//

import UIKit

extension UIViewController: UIGestureRecognizerDelegate {
    
    
    // MARK: - Observe keyboard Overrides
    
    @objc func keyBoardDidDisappear(){}
    
    @objc func keyBoardDidAppear(){}
    
    /// Override this method in ViewController for return bottom constraint.
    @objc func keyboardConstraint() -> NSLayoutConstraint? {
        return nil
    }
    
    /// UIScrollView for handle keyboard show notification.
    /// - Returns: main UIScrollView, it must be root item.
    func scroll() -> UIScrollView? {
        return self.view.subviews.first(where: { $0.isKind(of: UIScrollView.self) }) as? UIScrollView
    }
    
    // MARK: - Observe taps
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        self.navigationController?.navigationBar.endEditing(true)
    }
    
    // MARK: - Observe keyboard
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    func unobserveKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if self.keyboardConstraint() != nil {
            handleWithBottomContsraint(notification: notification)
        } else if let scrollView = scroll() {
            handleInScrollView(notification: notification, scrollView: scrollView)
        }
    }
    
    // MARK: - Private scroll methods
    
    private func handleWithBottomContsraint(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let keyboardHeightLayoutConstraint = self.keyboardConstraint() {
            let endFrameY = endFrame.origin.y
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= view.bounds.size.height/*UIScreen.main.bounds.size.height*/ {
                keyboardHeightLayoutConstraint.constant = 0.0
                self.keyBoardDidDisappear()
            } else {
                keyboardHeightLayoutConstraint.constant = endFrame.size.height
                self.keyBoardDidAppear()
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    private func handleInScrollView(notification: NSNotification, scrollView: UIScrollView) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        if keyboardFrame.origin.y >= view.bounds.size.height {
            scrollView.contentInset = .zero
            self.keyBoardDidDisappear()
        } else {
            var contentInset:UIEdgeInsets = scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height// + 20
            scrollView.contentInset = contentInset
            self.keyBoardDidAppear()
        }
    }
    
}
