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
    
    // firestore 데이터 불러오기 실패시 alert으로 예외 처리하기.
    func showLoadFailureAlert(withError error: Error) {
        let alertController = UIAlertController(title: "Load Failed", message: "There was an error loading the data: \(error.localizedDescription)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    /*
     사용 예시,
     1. if let
     } else if let err = err {
         print("Error getting documents: \(err)")
         DispatchQueue.main.async {
             self?.showLoadFailureAlert(withError: err)
         }
     }
     
     2. gaurd let일 때, gaurd let 블록 안에 작성
     DispatchQueue.main.async {
     self?.showLoadFailureAlert(withError: error!)
     }
     */
    
}
