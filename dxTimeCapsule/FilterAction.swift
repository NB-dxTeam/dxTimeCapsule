//
//  FilterAction.swift
//  dxTimeCapsule
//
//  Created by YeongHo Ha on 8/19/24.
//

import UIKit

protocol BoxFilterAction {
    func performAction()
}


class AllFilterAction: BoxFilterAction {
    private let viewController: CapsuleMapViewController
    
    init(viewController: CapsuleMapViewController) {
        self.viewController = viewController
    }
    
    func performAction() {
        viewController.loadCapsuleInfos(button: .all)
        viewController.showModalVC()
        viewController.updateButtonSelection(viewController.capsuleMapView.allButton)
    }
}

class LockedFilterAction: BoxFilterAction {
    private let viewController: CapsuleMapViewController
    
    init(viewController: CapsuleMapViewController) {
        self.viewController = viewController
    }
    
    func performAction() {
        viewController.loadCapsuleInfos(button: .locked)
        viewController.showModalVC()
        viewController.updateButtonSelection(viewController.capsuleMapView.lockedButton)
    }
}

class OpenedFilterAction: BoxFilterAction {
    private let viewController: CapsuleMapViewController
    
    init(viewController: CapsuleMapViewController) {
        self.viewController = viewController
    }
    
    func performAction() {
        viewController.loadCapsuleInfos(button: .opened)
        viewController.showModalVC()
        viewController.updateButtonSelection(viewController.capsuleMapView.openedButton)
    }
}
