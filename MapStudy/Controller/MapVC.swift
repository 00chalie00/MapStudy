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
// 4. MKMapviewDelegate Extension에 User 위치를 중앙으로 설정하는 func 구현
//    coordinate -> region -> mapView에 set
// 5. viewDidLoad에 TapGesture 객체 추가 -> Tap Number 설정 -> mapview에 Gesture 추가 (double tap시 Func 추가)
// 6. MKMapviewDelegate Extension에 doubletap func 구현
//    User가 Tap한 위치의 Location(CGPoint) 값을 구한다. -> Location Data를 CLLocationCoordinate2D로 convert -> Annotation Class 구현
// 7. Annotation 구현 (import UIKit, NSObject -> CLLocationCoordinate2D 변수 생성, identifier 변수 생성 -> init -> init 끝에 super.init())
// 8. MKMapviewDelegate Extension의 doubletap func에서 Annotation 객체 생성 -> mapview에 set
// 9. region -> center를 conver한 지점으로 생성 -> mapview에 set
//10. 기존 Annotation func 구현
//    for annotation in mapview.annotations로하는 for문 구현 ->mapview.removeannotation



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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(droppedPin(sender:)))
        tapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tapGesture)
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
    
    @objc func droppedPin(sender: UITapGestureRecognizer){
        removePin()
        
        let tapPosition = sender.location(in: mapView)
        let convertCoordinate = mapView.convert(tapPosition, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: convertCoordinate, identifier: "DroppedPin")
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: convertCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
}//End Of The Extension

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
}//End Of The Extension
