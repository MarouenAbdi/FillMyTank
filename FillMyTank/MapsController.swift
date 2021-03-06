//
//  MapsController.swift
//  FillMyTank
//
//  Created by marouenabdi on 17/01/2020.
//  Copyright © 2020 MarouenAbdi. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation

protocol MapsControllerDelegate : class {
    
    func mapsViewControllerDidSelectAnnotation(mapItem :MKMapItem)
}

class MapsController : UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var maps: MKMapView!
    weak var delegate :MapsControllerDelegate!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 5000
    var region = MKCoordinateRegion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maps.delegate = self
        checkLocationServices()
        locationManager.startUpdatingLocation()
        maps.showsUserLocation = true
        
        
    
        
    }
    
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {return}
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            maps.setRegion(region, animated: true)
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
        }
        
    }
    
    func setupLocationManager(){
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
             region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            maps.setRegion(region, animated: true)
            
        }
    }
    
    func checkLocationServices(){
        
        if CLLocationManager.locationServicesEnabled(){
            //setup the location manager.
            
            setupLocationManager()
        }
        else{
            //Show alert let the user know how to do it.
        }
    }
    
    
    //Adding the annotations on the maps
    
    func mapView(_ maps: MKMapView, didAdd views: [MKAnnotationView]){
        //print("Im here outside")
        let annotationView = views.first
        if let annotation = annotationView?.annotation{
            if annotation is MKUserLocation{
                //print("Im here inside")
                centerViewOnUserLocation()
                findStations()
            }
        }
        
        
    }
    
    
    
    //Finding the gas station in region and creating their annotations
    
    func findStations(){
        
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Gas station"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if response == nil {
                print("ERROR")
            }
            else{
                for item in response!.mapItems {
                
                let annotation = PlaceAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.mapItem = item
                
                DispatchQueue.main.async {
                    self.maps.addAnnotation(annotation)
                }
                
                
            }
            }
        
        
    }
    

}
    
    //The event when the user select an annotation
    
    func mapView(_ maps : MKMapView, didSelect view : MKAnnotationView){
        print("I'm selectedddd")
        let latitude = view.annotation?.coordinate.latitude
        let longitude = view.annotation?.coordinate.longitude
        let coordinate = CLLocationCoordinate2DMake(latitude!,longitude!)
                             let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                                mapItem.name = view.annotation?.title!
                             mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
}
