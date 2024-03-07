//
//  OpenCapsuleViewController.swift
//  dxTimeCapsule
//
//  Created by 김우경 on 3/7/24.
//

import Foundation
import UIKit
import SnapKit
import FirebaseFirestore

class OpenCapsuleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var documentId: String?
    private var memoriesCollectionView: UICollectionView!
    private var openingMessageLabel: UILabel!
    private var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupOpeningMessageLabel()
        setupMemoriesCollectionView()
        setupBackButton()
        
        // Firestore에서 타임캡슐 데이터 불러오기
        loadTimeCapsuleData()
    }
    
    private func setupOpeningMessageLabel() {
        openingMessageLabel = UILabel()
        openingMessageLabel.numberOfLines = 0
        openingMessageLabel.textAlignment = .center
        view.addSubview(openingMessageLabel)
        
        openingMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
    }
    
    private func setupMemoriesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 300)
        
        memoriesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        memoriesCollectionView.dataSource = self
        memoriesCollectionView.delegate = self
        memoriesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        memoriesCollectionView.backgroundColor = .white
        view.addSubview(memoriesCollectionView)
        
        memoriesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(openingMessageLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(300)
        }
    }
    
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.setTitle("뒤로 가기", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(memoriesCollectionView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .gray
        return cell
    }
    
    private func loadTimeCapsuleData() {
        guard let documentId = documentId else { return }
        
        let db = Firestore.firestore()
        db.collection("timeCapsules").document(documentId).getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else {
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let data = document.data()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 a hh시 mm분 ss초" // 원하는 날짜 형식 지정
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대 설정
            dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어로 표시
            
            if let creationDate = (data?["creationDate"] as? Timestamp)?.dateValue(),
               let openDate = (data?["openDate"] as? Timestamp)?.dateValue() {
                let creationDateString = dateFormatter.string(from: creationDate)
                let openDateString = dateFormatter.string(from: openDate)
                
                DispatchQueue.main.async {
                    self.openingMessageLabel.text = "개봉일: \(openDateString)\n생성일: \(creationDateString)"
                    // 여기에 더 많은 UI 업데이트 코드를 추가할 수 있습니다.
                }
            }
        }
    }
}
