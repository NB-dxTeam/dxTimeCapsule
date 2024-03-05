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
}
