//
//  MessageModalViewController.swift
//  dxTimeCapsule
//
//  Created by 김우경 on 3/19/24.
//

import Foundation
import UIKit

class MessageModalViewController: UIViewController {
    var creationDate: Date?
    var openDate: Date?
    var userMessage: String?
    
    private let gripView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 3
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        return textView
    }()
    
    private let daysAgoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureContent()
    }

    private func setupLayout() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16

        view.addSubview(gripView)
        view.addSubview(dateLabel)
        view.addSubview(messageTextView)
        view.addSubview(daysAgoLabel)
        
        gripView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        daysAgoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gripView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            gripView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gripView.widthAnchor.constraint(equalToConstant: 36),
            gripView.heightAnchor.constraint(equalToConstant: 6),
            
            dateLabel.topAnchor.constraint(equalTo: gripView.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            messageTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100), // 최소 높이 설정
            
            daysAgoLabel.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 20),
            daysAgoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysAgoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            daysAgoLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureContent() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let creationDateString = creationDate.map { dateFormatter.string(from: $0) } ?? "날짜 정보 없음"
        let openDateString = openDate.map { dateFormatter.string(from: $0) } ?? "날짜 정보 없음"
        
        dateLabel.text = "\(creationDateString) -> \(openDateString)"
        messageTextView.text = userMessage ?? "메시지가 없습니다."
        
        if let creationDate = creationDate {
            let daysAgo = Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
            daysAgoLabel.text = "\(daysAgo)일 전의 기억입니다."
        }
    }
}
