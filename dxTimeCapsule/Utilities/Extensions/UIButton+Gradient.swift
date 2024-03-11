import UIKit

extension UIButton {
    
    // MARK: - Button Theme
    
    // BlurryBeach 테마
    func setBlurryBeach() {
        setGradient(colors: [#colorLiteral(red: 0.831372549, green: 0.2, blue: 0.4117647059, alpha: 1), #colorLiteral(red: 0.7960784314, green: 0.6784313725, blue: 0.4274509804, alpha: 1)])
        setTitleColor(.white, for: .normal)
    }

    // AzurLane 테마
    func setInstagram() {
    
        setGradient(colors: [#colorLiteral(red: 0.5137254902, green: 0.2274509804, blue: 0.7058823529, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.1137254902, blue: 0.1137254902, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.6901960784, blue: 0.2705882353, alpha: 1)])

    }

    // custom1 테마
    func setCustom1() {
        setGradient(colors: [#colorLiteral(red: 1, green: 0.2274509804, blue: 0.2901960784, alpha: 1), #colorLiteral(red: 1, green: 0.6549019608, blue: 0.3176470588, alpha: 1)])

    }

    // Mango 테마
    func setMango() {
        setGradient(colors: [#colorLiteral(red: 1, green: 0.8862745098, blue: 0.3490196078, alpha: 1), #colorLiteral(red: 1, green: 0.6549019608, blue: 0.3176470588, alpha: 1)])

    }

    
    // PurpleParadise 테마
    func setPurpleParadise() {
        setGradient(colors: [#colorLiteral(red: 0.114, green: 0.168, blue: 0.392, alpha: 1.0), #colorLiteral(red: 0.972, green: 0.8, blue: 0.855, alpha: 1.0)])

    }

    // Broken Heart 테마
    func setBrokenHeart() {
        setGradient(colors: [#colorLiteral(red: 0.8470588235, green: 0.6549019608, blue: 0.7803921569, alpha: 1), #colorLiteral(red: 1, green: 0.9882352941, blue: 0.862745098, alpha: 1)])
    }
    
    // Kye Meh 테마
    func setKyeMeh() {
        setGradient(colors: [#colorLiteral(red: 0.5124089718, green: 0.3768126369, blue: 0.7636634707, alpha: 1), #colorLiteral(red: 0.1767435968, green: 0.750133276, blue: 0.5680578351, alpha: 1)])
    }
    
    // Dark Ocdeon
    func setDarkOcdeon() {
        setGradient(colors: [#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), #colorLiteral(red: 0.2588235294, green: 0.5254901961, blue: 0.9568627451, alpha: 1)])
    }
    
    // Sin City Red
    func setSinCityRed() {
        setGradient(colors: [#colorLiteral(red: 1, green: 0.2274509804, blue: 0.2901960784, alpha: 1), #colorLiteral(red: 0.5764705882, green: 0.1607843137, blue: 0.1176470588, alpha: 1)])
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
    
    // 단색 버튼
    func configureButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(hex: "#FF3A4A")
        button.titleLabel?.font = UIFont.pretendardSemiBold(ofSize: 16)
        
        // 그림자 설정
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 6 // 그림자의 블러 정도 설정 (조금 더 부드럽게)
        button.layer.shadowOpacity = 0.3 // 그림자의 투명도 설정 (적당한 농도로)
        button.layer.shadowOffset =  CGSize(width: 0, height: 3) // 그림자 방향 설정 (아래로 조금 더 멀리)
        
        
        button.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
}
