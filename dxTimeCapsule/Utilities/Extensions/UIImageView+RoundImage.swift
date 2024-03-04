import UIKit

extension UIImageView {
    func setRoundedImage(named imageName: String? = nil, url: URL? = nil, placeholder: UIImage? = UIImage(named: "defaultProfileImage")) {
        if let imageName = imageName {
            self.image = UIImage(named: imageName)?.roundedImage()
        } else if let url = url {
            // Use SDWebImage for loading the image from URL and then rounding it
            self.sd_setImage(with: url, placeholderImage: placeholder, completed: { [weak self] (image, error, cacheType, imageURL) in
                self?.image = image?.roundedImage()
            })
        } else {
            self.image = placeholder?.roundedImage()
        }
        
        // Ensure that the UIImageView itself has the same corner radius as the image for a consistent appearance
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
