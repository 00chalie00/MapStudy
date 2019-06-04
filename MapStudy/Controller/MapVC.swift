//
//  ViewController.swift
//  MapStudy
//
//  Created by formathead on 30/05/2019.
//  Copyright © 2019 formathead. All rights reserved.
// added Extension

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage
import SwiftyJSON

class MapVC: UIViewController {

    //Outlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var upviewConstrain: NSLayoutConstraint!
    @IBOutlet weak var upView: UIView!
    
    let locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 100
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    var screenSize = UIScreen.main.bounds
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageArray = [String]()
    var imageDNArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationService()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(droppedPin(sender:)))
        tapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tapGesture)
        
        //CollectionView Code 구현
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.green
        upView.addSubview(collectionView!)
        
    }

    
    @IBAction func MapCenterPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapUserLocation()
        }
    }
    
    func animateViewUp() {
        upviewConstrain.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSession()
        upviewConstrain.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addspinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = UIColor.red
        spinner?.startAnimating()
        upView.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    @objc func addSwipe() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipeGesture.direction = .down
        upView.addGestureRecognizer(swipeGesture)
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = UIColor.darkGray
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
}//End Of The Class

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DroppedPin")
        pinAnnotation.pinTintColor = UIColor.orange
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func droppedPin(sender: UITapGestureRecognizer){
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSession()
        
        imageArray = []
        imageDNArray = []
        
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addspinner()
        addProgressLbl()
        
        let tapPosition = sender.location(in: mapView)
        let convertCoordinate = mapView.convert(tapPosition, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: convertCoordinate, identifier: "DroppedPin")
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: convertCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (success) in
            if success {
                self.retrieveImage(completion: { (success) in
                    if success {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    //지정된 Pin에 대한 Image의 URL로 Image Array 획득
    func retrieveUrls(forAnnotation annotation: DroppablePin, completion: @escaping completionHandler) {
        Alamofire.request(flickerUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_b.jpg"
                self.imageArray.append(postUrl)
            }
            completion(true)
        }
    }
    
    func retrieveImage(completion: @escaping completionHandler) {
        imageDNArray = []
        
        for url in imageArray {
            Alamofire.request(url).responseImage(completionHandler: {(response) in
                guard let image = response.result.value else { return }
                self.imageDNArray.append(image)
                self.progressLbl?.text = "\(self.imageDNArray.count)/40 IMAGES DOWNLOADED"
                if self.imageDNArray.count == self.imageArray.count {
                    completion(true)
                }
            })
        }
    }
    
    func cancelAllSession() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        let imageForIndex = imageDNArray[indexPath.row]
        let imageView = UIImageView(image: imageForIndex)
        cell.addSubview(imageView)
        
        return cell
    }
    
    
}
