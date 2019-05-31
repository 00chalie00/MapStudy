//
//  DrappablePin.swift
//  MapStudy
//
//  Created by formathead on 31/05/2019.
//  Copyright © 2019 formathead. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
}//End Of The Class

