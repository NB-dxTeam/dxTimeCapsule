// UIViewController+Debugging.swift
import UIKit

extension UIViewController {
    func printViewHierarchy() {
        print("\n뷰 계층 구조:\n")
        printViewHierarchy(view: self.view, indentLevel: 0)
    }
    
    private func printViewHierarchy(view: UIView, indentLevel: Int) {
        let indent = String(repeating: " ", count: indentLevel * 2) // 들여쓰기
        let viewDescription = "\(indent)- \(view.description)"
        print(viewDescription)
        
        // 서브뷰에 대해 재귀적으로 함수 호출
        view.subviews.forEach { subview in
            printViewHierarchy(view: subview, indentLevel: indentLevel + 1)
        }
    }
    
    // 키보드 다른 곳 탭 동작시 숨기기
    func keyBoardHide(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyBoard(){
        view.endEditing(true)
    }
    
}

// MARK: - 텍스트필드 반응에 따라 스크린 올리기
extension UIViewController {
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let activeTextField = UIResponder.currentFirstResponder as? UITextField else { return }
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        
        let activeTextFieldFrame: CGRect? = activeTextField.superview?.convert(activeTextField.frame, to: view)
        
        if let activeTextFieldFrame = activeTextFieldFrame, !aRect.contains(activeTextFieldFrame.origin) {
            let diff = activeTextFieldFrame.origin.y - aRect.size.height + activeTextFieldFrame.size.height
            view.frame.origin.y -= diff
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
}
