import UIKit
import SnapKit

class EmojiCell: UICollectionViewCell {
    // MARK: - Properties
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(emojiLabel)
        emojiLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    func configure(with emoji: Emoji) {
        emojiLabel.text = emoji.symbol
    }
}
