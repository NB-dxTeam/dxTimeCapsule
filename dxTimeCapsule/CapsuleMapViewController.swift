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
    
    // 임시 네비게이션 바
    private lazy var nvBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    private lazy var capsuleMap: NMFMapView = {
        let map = NMFMapView()
        
        return map
    }()
    private var capsuleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        //layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBlue
        return collection
    }()
    private let dragBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = .black
        bar.layer.cornerRadius = 3
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        autoLayouts()
        viewDidLayoutSubviews()
        configCV()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        capsuleCollectionView.layer.cornerRadius = 30
        capsuleCollectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        capsuleCollectionView.layer.masksToBounds = true
    }
    
    private func configCV() {
        capsuleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        capsuleCollectionView.delegate = self
        capsuleCollectionView.dataSource = self
        capsuleCollectionView.register(LockedCapsuleCell.self, forCellWithReuseIdentifier: LockedCapsuleCell.identifier)
        
        if let layout = capsuleCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: view.frame.width - 48, height: 120)
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        }
    }
}

extension CapsuleMapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 // 임시 설정.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LockedCapsuleCell", for: indexPath) as? LockedCapsuleCell else {fatalError("Unable to dequeue CapsuleCollectionViewCell")}
        
        return cell
    }
    
}

extension CapsuleMapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = 12 * (2 - 1)
        let itemWidth = capsuleCollectionView.bounds.width - 48
        let itemHeight = capsuleCollectionView.bounds.height / 2 - 18
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
// MARK: - UI AutoLayout
extension CapsuleMapViewController {
    private func addSubViews() {
        self.view.addSubview(nvBar)
        self.view.addSubview(capsuleMap)
        self.view.addSubview(capsuleCollectionView)
        self.view.addSubview(dragBar)
    }
    private func autoLayouts() {
        nvBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        capsuleMap.snp.makeConstraints { make in
            make.top.equalTo(nvBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(capsuleCollectionView.snp.top)
            
        }
        
        capsuleCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.height.equalTo(350)
        }
        
        dragBar.snp.makeConstraints { make in
            make.centerX.equalTo(capsuleCollectionView.snp.centerX)
            make.top.equalTo(capsuleCollectionView.snp.top).offset(12)
            make.width.equalTo(60)
            make.height.equalTo(5)
        }
    }
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
