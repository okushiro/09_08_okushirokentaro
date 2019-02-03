//
//  ViewController.swift
//  MapApp
//
//  Created by 奥城健太郎 on 2019/02/03.
//  Copyright © 2019 奥城健太郎. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapCanvasView: UIView!
    
    @IBOutlet weak var outputLabel: UILabel!
    
//    let defaultLatitude = 35.6675497
//    let defaultLongitude = 139.7137988
    let defaultZoomLevel:Float = 14.0
    var mapView : GMSMapView!
    var locationManager = CLLocationManager()
    
    let marker = GMSMarker()
    
    var lat:Double = 35.6675497
    var lng:Double = 139.7137988
    var currentValue:Double = 0.0
    
//    var markerLat:Double = 35.6675497
//    var markerLng:Double = 139.7137988
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        
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
    
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locations.last?.coordinate {
            lat = Double(coordinate.latitude)
            lng = Double(coordinate.longitude)
            
            let camera = GMSCameraPosition.camera(withLatitude:lat, longitude:lng, zoom:14.0)
            self.mapView.animate(with:GMSCameraUpdate.setCamera(camera))
            
            //自分の標高取得
            let url = "https://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?lon=\(String(lng))&lat=\(String(lat))&outtype=JSON"
            
            Alamofire.request(
                url,
                method: .get,
                parameters: [:],
                encoding: URLEncoding.default,
                headers: nil
                )
                .responseJSON{(response: DataResponse<Any>) in
                    let json = JSON(response.result.value as Any)
                    if let value = json["elevation"].double{
                        self.currentValue = value
                    }
                }
            
//            print("緯度:\(String(describing: coordinate.latitude)) 経度:\(String(describing: coordinate.longitude)) 取得時刻:\(String(describing: locations.last?.timestamp.description))")
            
        }
    }
        
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        //マーカー移動
        self.marker.position = coordinate
        //        mapView.animate(toLocation: coordinate)
        
        //マーカーの標高取得
        let urlLat = Double(coordinate.latitude)
        let urlLng = Double(coordinate.longitude)
        let url = "https://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?lon=\(String(urlLng))&lat=\(String(urlLat))&outtype=JSON"
        print(url)
        
        Alamofire.request(
            url,
            method: .get,
            parameters: [:],
            encoding: URLEncoding.default,
            headers: nil
            )
            .responseJSON{(response: DataResponse<Any>) in
                let json = JSON(response.result.value as Any)
                if let markerValue = json["elevation"].double{
                    let output:Double = markerValue - self.currentValue
                    self.outputLabel.text = "\(String(format: "%.1f",output)) m"
                    self.marker.title = "\(String(format: "%.1f",markerValue)) m"
                    if output > 0 {
                        self.view.backgroundColor = UIColor.init(red: 242/255, green: 140/255, blue: 187/255, alpha: 0.8)
                    }else if output < 0 {
                        self.view.backgroundColor = UIColor.init(red: 67/255, green: 135/255, blue: 233/255, alpha: 0.7)
                    }
                    
                }
            }
        }
}

