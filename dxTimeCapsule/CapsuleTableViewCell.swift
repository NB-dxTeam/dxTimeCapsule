import UIKit
import SnapKit

class CapsuleTableViewCell: UITableViewCell {
    let capsuleImageView = UIImageView()
    let descriptionLabel = UILabel()
    let openDateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(capsuleImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(openDateLabel)

        capsuleImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(100)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(capsuleImageView.snp.top)
            make.leading.equalTo(capsuleImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        openDateLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.equalTo(descriptionLabel.snp.leading)
            make.trailing.equalTo(descriptionLabel.snp.trailing)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        descriptionLabel.numberOfLines = 0
    }

    func configure(with capsule: TimeBox) {
        // 이미지 설정 (실제 앱에서는 imageURL을 사용하여 이미지를 로드합니다)
        capsuleImageView.image = UIImage(named: "placeholder")
        // 설명 설정
        descriptionLabel.text = capsule.description
        // 개봉일 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        openDateLabel.text = "Open Date: \(dateFormatter.string(from: capsule.openTimeBoxDate))"
    }
}
