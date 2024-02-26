import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel {
    private let db = Firestore.firestore()
    
    var email: String = ""
    var password: String = ""
    
    // 상태 업데이트를 위한 클로저
    var onAuthStateChanged: ((Bool, String?) -> Void)?
    
    // 회원가입 함수
    func signUp(email: String, password: String, nickname: String) {
        // Firebase Authentication을 사용하여 사용자 생성
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            
            // 사용자 생성 성공, Firestore에 추가 정보 저장
            guard let userId = authResult?.user.uid else { return }
            let userDocument = Firestore.firestore().collection("users").document(userId)
            
            userDocument.setData([
                "nickname": nickname,
                // 여기에 추가 정보를 포함시킵니다.
            ]) { error in
                if let error = error {
                    print("Error saving user information: \(error.localizedDescription)")
                } else {
                    print("User information saved successfully")
                }
            }
        }
    }



    
    // 로그인 함수
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }
            // 성공적으로 로그인된 경우의 처리
            print("User logged in successfully")
        }
    }

}
