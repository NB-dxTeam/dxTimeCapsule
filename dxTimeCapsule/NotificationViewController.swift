//
//  NotificationViewController.swift
//  dxTimeCapsule
//
//  Created by t2023-m0028 on 2/27/24.
//

import UIKit
import SnapKit

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // 테이블 뷰 선언
    let tableView = UITableView()

    // 첫 번째 섹션에 들어갈 이미지 배열과 라벨 데이터
    let cutePandaImages = ["Panda1", "Panda2"]
    let cutePandaLabels = ["Panda님이 당신에게 친구를 신청했습니다", "Kuma님과 당신이 친구가 되었습니다"]

    // 두 번째 섹션에 들어갈 이미지 배열과 라벨 데이터
    let naughtyPandaImages = ["Panda3", "Panda4", "Panda5", "Panda6", "Panda7"]
    let naughtyPandaLabels = ["2021년11월12일에 서울시 영등포구 여의도동에서 만든 타임캡슐이 개봉될 준비가 되었습니다", "2021년11월12일에 서울시 영등포구 여의도동에서 만든 타임캡슐이 개봉될 준비가 되었습니다", "2021년11월12일에 서울시 영등포구 여의도동에서 만든 타임캡슐이 개봉될 준비가 되었습니다", "2021년11월12일에 서울시 영등포구 여의도동에서 만든 타임캡슐이 개봉될 준비가 되었습니다", "2021년11월12일에 서울시 영등포구 여의도동에서 만든 타임캡슐이 개봉될 준비가 되었습니다"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "알림"

        // 테이블 뷰 속성 설정
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }

    // 섹션의 개수를 반환하는 메서드
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // 각 섹션의 행의 개수를 반환하는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 섹션에 따라 다른 행의 개수를 반환
        if section == 0 {
            return cutePandaImages.count
        } else {
            return naughtyPandaImages.count
        }
    }

    // 각 셀에 대한 설정을 하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationTableViewCell

        // 각 섹션에 따라 다른 이미지와 라벨 데이터를 표시
        if indexPath.section == 0 {
            cell.cellImageView.image = UIImage(named: cutePandaImages[indexPath.row])
            cell.contentLabel.text = cutePandaLabels[indexPath.row]
        } else {
            cell.cellImageView.image = UIImage(named: naughtyPandaImages[indexPath.row])
            cell.contentLabel.text = naughtyPandaLabels[indexPath.row]
        }

        return cell
    }

    // 각 셀의 높이를 설정하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // 헤더의 속성을 정의하는 메서드
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()

        // 헤더의 라벨 속성 설정
        let label = UILabel()
        label.text = section == 0 ? "친구 신청" : "타임캡슐 개봉"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .left

        // 라벨을 헤더 뷰에 추가
        headerView.addSubview(label)

        // 라벨의 제약 설정
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: headerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        return headerView
    }
}
