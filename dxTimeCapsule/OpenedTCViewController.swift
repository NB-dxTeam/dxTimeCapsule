import UIKit
import SnapKit

#Preview{
    OpenedTCViewController()
}

class OpenedTCViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    // Dummy data
    let images = ["Panda1", "Panda2", "Panda3", "Panda4", "Panda5", "Panda6", "Panda7"]
    let topLabelData = ["Title 1", "Title 2", "Title 3", "Title 4", "Title 5", "Title 6", "Title 7"]
    let bottomLabelData = ["Description 1", "Description 2", "Description 3", "Description 4", "Description 5", "Description 6", "Description 7"]
    
    // MARK: - UI Components
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OpendedTCCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = "저장된 타임캡슐"
        view.addSubview(collectionView)
        view.addSubview(pageControl)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(images.count, topLabelData.count, bottomLabelData.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OpendedTCCollectionViewCell
        let imageData = images[indexPath.item]
        let topLabel = topLabelData[indexPath.item]
        let bottomLabel = bottomLabelData[indexPath.item]
        cell.configure(with: imageData, topLabelData: topLabel, bottomLabelData: bottomLabel)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 40
        let height = collectionView.frame.height / 5 - 20
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20 // Adjust as needed
    }
}
