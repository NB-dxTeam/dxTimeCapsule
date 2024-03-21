import UIKit
import SnapKit

class EmojiCell: UICollectionViewCell {
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(emojiLabel)
        contentView.addSubview(descriptionLabel)
        
        emojiLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emojiLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(with emoji: Emoji) {
        emojiLabel.text = emoji.symbol
        descriptionLabel.text = emoji.description
    }
}
