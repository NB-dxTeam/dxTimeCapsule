//
//  MainViewModel.swift
//  dxTimeCapsule
//
//  Created by t2023-m0031 on 3/5/24.
//

import UIKit
import MapKit

class MainViewModel: NSObject, MKMapViewDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 37.334_900,
            longitude: -122.009_020),
        latitudinalMeters: 750,
        longitudinalMeters: 750
    )
}
