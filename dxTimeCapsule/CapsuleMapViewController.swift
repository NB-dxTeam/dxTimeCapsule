//
//  CapsuleMapViewController.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 2/24/24.
//

import UIKit
import NMapsMap
import CoreLocation
import SnapKit

class CapsuleMapViewController: UIViewController {
    private lazy var nvBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    private lazy var capsuleMap: NMFMapView = {
        let map = NMFMapView(frame: view.frame)
        return map
    }()
//    private var pageControl: UIPageControl = { // 컬렉션 뷰 페이지
//        let page = UIPageControl()
//        page.currentPage = 0
//        page.numberOfPages = 4 // 임시
//        page.currentPageIndicatorTintColor = .black
//        page.pageIndicatorTintColor = .white
//        return page
//    }()
    // 콜렉션 뷰 원래 높이
    private var collectionHeight: CGFloat?
    // 콜렉션 뷰 드래그 할 떄, 마지막 y좌표 저장 변수
    private var lastY: CGFloat = 0
    private var flowLayout: UICollectionViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        autoLayouts()
        showModalVC()
    }
    
    
    func showModalVC() {
        let vc = CustomModal()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]

            sheet.prefersGrabberVisible = true // 모달에 Grabber 나타내기
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false // 스크롤 확장 여부
            sheet.largestUndimmedDetentIdentifier = .medium // 모달 외에 view 흐림처리 방지.
        }
        self.present(vc, animated: true)
    }
}
// MARK: - UICollectionView Delegate, DataSource
extension CapsuleMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8 // 임시 설정.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LockedCapsuleCell", for: indexPath) as? LockedCapsuleCell else {fatalError("Unable to dequeue CapsuleCollectionViewCell")}
        return cell
    }
    
}

extension CapsuleMapViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // 클래스 프로퍼티를 사용
//        if let layout = self.flowLayout {
//            let width = scrollView.frame.width - (layout.sectionInset.left + layout.sectionInset.right)
//            let index = Int((scrollView.contentOffset.x + (0.5 * width)) / width)
//            pageControl.currentPage = max(0, min(pageControl.numberOfPages - 1, index))
//        }
//       
//    }
}

// MARK: - UI AutoLayout
extension CapsuleMapViewController {
    private func addSubViews() {
        self.view.addSubview(nvBar)
        self.view.addSubview(capsuleMap)
        //self.view.addSubview(pageControl)
    }
    
    private func autoLayouts() {
        nvBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        capsuleMap.snp.makeConstraints { make in
            make.top.equalTo(nvBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-350)
        }
//        pageControl.snp.makeConstraints { make in
//            make.centerX.equalTo(view.snp.centerX)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
//        }
    }
    
}


// MARK: - Button
extension CapsuleMapViewController {
//    @objc func pageControlDidChange(_ sender: UIPageControl) {
//        let current = sender.currentPage
//        capsuleCollectionView.scrollToItem(at: IndexPath(item: current, section: 0), at: .centeredHorizontally, animated: true)
//    }
}


// MARK: - Preview
import SwiftUI

struct PreView: PreviewProvider {
    static var previews: some View {
        CapsuleMapViewController().toPreview()
    }
}

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif

