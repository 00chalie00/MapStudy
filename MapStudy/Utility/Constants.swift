//
//  Constants.swift
//  MapStudy
//
//  Created by formathead on 03/06/2019.
//  Copyright © 2019 formathead. All rights reserved.
//

import Foundation

typealias completionHandler = (_ status: Bool) -> ()

let API_KEY = "7053f1abef35f2ccc5c8870ade4f27b8"

func flickerUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.latitude)&format=json&nojsoncallback=1"
    //"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
    //"https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&page=\(number)&format=rest"
}

