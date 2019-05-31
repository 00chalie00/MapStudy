//
//  ViewController.swift
//  MapStudy
//
//  Created by formathead on 30/05/2019.
//  Copyright © 2019 formathead. All rights reserved.
// added Extension
// 1. import Mapkit -> MapView outlet 생성 -> Mapview Delegate 설정 -> extension으로 MKMapviewDelegate 설정 (Class 외부에 설정)
// 2. import CoreLocation -> CLLocationManager 객체 생성 -> locationManager Delegate 설정 -> extension으로 CLLocationManagerDelegate 설정 (Class 외부에 설정)
// 3. 권한 관련하여 CLLOcationManager.authorizationStatus 객체 생성 -> CLLocationManagerDelegate에 생성한 authorizationStatus 객체가 .notDetermined auth request -> plist에 권한 관련 3가지 추가 (항상, 사용시, 거절)
// 4. MKMapviewDelegate에 User 위치를 중앙으로 설정하는 func 작성
//    coordinate -> region -> mapView에 설정



import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    //Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 100
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationService()
    }

    
    @IBAction func MapCenterPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapUserLocation()
        }
    }
    
}//End Of The Class

extension MapVC: MKMapViewDelegate {
    func centerMapUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationService() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapUserLocation()
    }
}
