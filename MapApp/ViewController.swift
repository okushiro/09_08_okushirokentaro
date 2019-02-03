//
//  ViewController.swift
//  MapApp
//
//  Created by 奥城健太郎 on 2019/02/03.
//  Copyright © 2019 奥城健太郎. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapCanvasView: UIView!
//    let defaultLatitude = 35.6675497
//    let defaultLongitude = 139.7137988
    let defaultZoomLevel:Float = 14.0
    var mapView : GMSMapView!
    var locationManager = CLLocationManager()
    
    let marker = GMSMarker()
    
    var lat:Double = 35.6675497
    var lng:Double = 139.7137988
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: defaultZoomLevel)
        let frame = CGRect(x: 0, y: 0, width: mapCanvasView.frame.width, height: mapCanvasView.frame.height)
        self.mapView = GMSMapView.map(withFrame: frame, camera: camera)
        self.mapView.isMyLocationEnabled = true;
        self.mapView.settings.myLocationButton = true;
        self.mapView.delegate = self
        
        self.locationManager.activityType = .other
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        
        self.locationManager.startUpdatingLocation()
        
        self.mapCanvasView.addSubview(self.mapView)
        
        marker.position.latitude = lat
        marker.position.longitude = lng
        marker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        self.marker.position = coordinate
        //        mapView.animate(toLocation: coordinate)
    }


}

