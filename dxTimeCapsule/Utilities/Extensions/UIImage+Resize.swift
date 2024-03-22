import UIKit

extension UIImage {
    func resizedToFourFiveRatio() -> UIImage? {
        let targetRatio: CGFloat = 4.0 / 5.0
        let originalRatio = size.width / size.height
        var targetSize = CGSize()

        if originalRatio > targetRatio { // 이미지가 너무 넓은 경우
            targetSize.height = size.height
            targetSize.width = size.height * targetRatio
        } else { // 이미지가 너무 높은 경우
            targetSize.width = size.width
            targetSize.height = size.width / targetRatio
        }

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newWidth = size.width * scaleFactor
        let newHeight = size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)

        // 그래픽스 컨텍스트에서 이미지 다시 그리기
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
