//
//  DatePickerModalViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/9/24.
//

import UIKit

class DatePickerModalViewController: UIViewController {
    
    var datePicker: UIDatePicker!
    var selectDateAction: ((Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDatePicker()
        setupActions()
    }
    
    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    private func setupActions() {
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Select", for: .normal)
        view.addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        selectButton.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
    }
    
    @objc private func selectDate() {
        dismiss(animated: true) {
            self.selectDateAction?(self.datePicker.date)
        }
    }
    


    
}
