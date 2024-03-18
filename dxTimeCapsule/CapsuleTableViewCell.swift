import UIKit
import SnapKit
import Kingfisher

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
    
    func configure(with timeBox: TimeBox) {
        // 이미지 설정 (실제 앱에서는 imageURL을 사용하여 이미지를 로드합니다)
        if let imageURL = timeBox.imageURL?.first, let url = URL(string: imageURL) {
            // Kingfisher를 사용하여 이미지 로드
            capsuleImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        } else {
            capsuleImageView.image = UIImage(named: "placeholder")
        }

        // 설명 설정
        descriptionLabel.text = timeBox.description

        // 개봉일 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let openTimeBoxDate = timeBox.openTimeBoxDate {
            /*
             
            // MARK: - 여기 수정해야됨. 기존 프로퍼티가 "Date -> TimeStamp 로 변경" 03/18 황주영
             
            openDateLabel.text = "Open Date: \(dateFormatter.string(from: openTimeBoxDate))"
             
             */
            
        } else {
            openDateLabel.text = "Open Date: N/A" // 개봉일이 없는 경우에 대한 처리
        }
    }

}
