import UIKit

extension UIButton {
    
    // MARK: - Button Theme
    
    // BlurryBeach 테마
    func setBlurryBeach() {
        setGradient(colors: [#colorLiteral(red: 0.831372549, green: 0.2, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.7960784314, green: 0.6784313725, blue: 0.4274509804, alpha: 1)])
        setTitleColor(.white, for: .normal)
    }

    // AzurLane 테마
    func setThemeAzurLane() {
        setGradient(colors: [#colorLiteral(red: 0.4980392157, green: 0.4980392157, blue: 0.8352941176, alpha: 1), #colorLiteral(red: 0.5254901961, green: 0.6588235294, blue: 0.9058823529, alpha: 1), #colorLiteral(red: 0.568627451, green: 0.9176470588, blue: 0.8941176471, alpha: 1)])

    }

    // ViceCity 테마
    func setThemeViceCity() {
        setGradient(colors: [#colorLiteral(red: 0.2039215686, green: 0.5803921569, blue: 0.9019607843, alpha: 1), #colorLiteral(red: 0.9254901961, green: 0.431372549, blue: 0.6784313725, alpha: 1)])

    }

    // Mango 테마
    func setThemeMango() {
        setGradient(colors: [#colorLiteral(red: 1, green: 0.8862745098, blue: 0.3490196078, alpha: 1), #colorLiteral(red: 1, green: 0.6549019608, blue: 0.3176470588, alpha: 1)])

    }

    // Mango Custom 테마
    func setThemeMangoustom() {
        setGradient(colors: [#colorLiteral(red: 1, green: 0.8862745098, blue: 0.3490196078, alpha: 1), #colorLiteral(red: 0.7894003391, green: 0.2963732481, blue: 0.2954288721, alpha: 1)])

    }
    
    // PurpleParadise 테마
    func setThemePurpleParadise() {
        setGradient(colors: [#colorLiteral(red: 0.114, green: 0.168, blue: 0.392, alpha: 1.0), #colorLiteral(red: 0.972, green: 0.8, blue: 0.855, alpha: 1.0)])

    }

    // Broken Heart 테마
    func setThemeBrokenHeart() {
        setGradient(colors: [#colorLiteral(red: 0.8470588235, green: 0.6549019608, blue: 0.7803921569, alpha: 1), #colorLiteral(red: 1, green: 0.9882352941, blue: 0.862745098, alpha: 1)])
    }

    // 버튼 그라데이션 적용 확장
    func setGradient(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = self.layer.cornerRadius
        self.layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = 8

        
    }
    
}
