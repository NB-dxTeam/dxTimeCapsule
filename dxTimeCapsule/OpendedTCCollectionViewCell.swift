import UIKit
import SnapKit

class OpendedTCCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    // Image View Declaration
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // Top Label Declaration
    let topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    // Bottom Label Declaration
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add Subviews
        addSubview(imageView)
        addSubview(topLabel)
        addSubview(bottomLabel)
        
        // Set corner radius and border for cell
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        
        // Constraints using SnapKit
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.width.height.lessThanOrEqualTo(60)
            make.height.equalTo(self.snp.height).offset(-20) //
        }
        
        topLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(bottomLabel.snp.height).multipliedBy(3) // Set Top label height twice of bottom label height
        }
        
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(10)
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with image: String, topLabelData: String?, bottomLabelData: String?) {
        imageView.image = UIImage(named: image)
        topLabel.text = topLabelData ?? ""
        bottomLabel.text = bottomLabelData ?? ""
    }
}
