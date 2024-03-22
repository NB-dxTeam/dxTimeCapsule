//
//  TermsTableViewCell.swift
//  dxTimeCapsule
//
//  Created by Lee HyeKyung on 3/14/24.
//

import UIKit
import SnapKit

class TermsTableViewCell: UITableViewCell {
    
    private let checkboxButton = UIButton()
    private let termsLabel = UILabel()
    
    // 초기화 메서드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 레이아웃 설정 메서드 호출
        setupLayouts()
        // 버튼 액션 설정 메서드 호출
        setupActions()
        // 액세서빌리티 설정 메서드 호출
        setupAccessibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 재사용 준비 메서드
    override func prepareForReuse() {
        super.prepareForReuse()
        // 체크 상태를 초기화하지만, isSelected의 기본값은 false로 설정되어 있으므로 이 줄은 생략해도 됩니다.
        checkboxButton.isSelected = false
    }
    
    // 셀 구성 메서드
    func configure(with title: String, isChecked: Bool) {
        termsLabel.text = title
        checkboxButton.isSelected = isChecked
        // 체크박스의 외형을 업데이트하는 메서드 호출
        updateCheckboxAppearance()
    }
    
    // 레이아웃 설정 메서드
    private func setupLayouts() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(termsLabel)
        // 체크박스 버튼 레이아웃
        checkboxButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24) // 체크박스 아이콘 크기
        }
        
        // 약관 라벨 레이아웃
        termsLabel.snp.makeConstraints { make in
            make.left.equalTo(checkboxButton.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        
    }
    
    // 버튼 액션 설정 메서드
    private func setupActions() {
        checkboxButton.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)
    }
    
    // 체크박스 토글 메서드
    @objc private func toggleCheckbox() {
        checkboxButton.isSelected.toggle()
        // 체크박스의 외형을 업데이트하는 메서드 호출
        updateCheckboxAppearance()
    }
    
    // 체크박스 외형 업데이트 메서드
    private func updateCheckboxAppearance() {
        let symbolName = checkboxButton.isSelected ? "checkmark.circle.fill" : "circle"
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfig)
        checkboxButton.setImage(symbolImage, for: .normal)
    }
    
    // 액세서빌리티 설정 메서드
    private func setupAccessibility() {
        // 체크박스 버튼에 액세서빌리티 트레이트 설정
        checkboxButton.isAccessibilityElement = true
        checkboxButton.accessibilityTraits = .button
        // 약관 라벨에 액세서빌리티 트레이트 설정
        termsLabel.isAccessibilityElement = true
        termsLabel.accessibilityTraits = .staticText
    }
}
