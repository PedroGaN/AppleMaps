//
//  ViewController.swift
//  Maps
//
//  Created by alumnos on 25/01/2021.
//  Copyright © 2021 alumnos. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMaps
import GooglePlaces

class MapsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let pointsOfInterest = [
        CLLocationCoordinate2DMake(40.642500026153755, -4.155350915798264),
        CLLocationCoordinate2DMake(40.0, -4.0),
        CLLocationCoordinate2DMake(40.2, -4.1),
        CLLocationCoordinate2DMake(40.3, -4.2)
    ]

    var userLocation: CLLocation?
    
    var manager : CLLocationManager?

    @IBOutlet weak var mapView: MKMapView!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager = CLLocationManager()
        manager!.delegate = self
        
        mapView.delegate = self
        
        getRoute()
        
        let location = CLLocationCoordinate2DMake(0, 0)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
       
        
        
    }
    
    private func loadRoute() {
        
        let originCoordinate = pointsOfInterest[0]
        let destinyCoordinate = pointsOfInterest[1]
        
        let mkPlacemarkOrigin = MKPlacemark(coordinate: originCoordinate)
        let mkPlacemarkDestiny = MKPlacemark(coordinate: destinyCoordinate)

        let origin = MKMapItem(placemark: mkPlacemarkOrigin)
        let destiny = MKMapItem(placemark: mkPlacemarkDestiny)
        
        let peticion = MKDirections.Request()
        peticion.source = origin
        peticion.destination = destiny
        peticion.transportType = .any
        
        let indications = MKDirections(request: peticion)

        indications.calculate { (respuesta, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.mapView.addOverlay(respuesta!.routes[0].polyline)

            }
            
        }
            
    }
    
    //var first = true
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        

            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 10
            return renderer

        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print(view.annotation?.coordinate)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
            
        manager!.requestAlwaysAuthorization()
        
        pointsOfInterest.forEach { point in
            
            let anotacion = MKPointAnnotation()
            anotacion.coordinate = point
            anotacion.title = "Neverland"
            anotacion.subtitle = "El pais de nunca jamas"
            mapView.addAnnotation(anotacion)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if(!locations.isEmpty){
            print(locations[0])
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if(status != .denied){
            manager.startUpdatingLocation()
        }
        
    }

    func getRoute(){
        
        let destination = "Toronto"
        let origin = "Montreal"
        
        NetworkManager.shared.getRoute(origin: origin, destination: destination, completion: {routes in
            
            let path = GMSPath.init(fromEncodedPath: routes[0].overviewPolyline.points)
            print(path?.count())
            
            var points: [CLLocationCoordinate2D] = []
            
            for index in 0...(path?.count())!{
                points.append((path?.coordinate(at: index))!)
            }
            
            
            let count = (points.count)-1
            let polyline = MKPolyline(coordinates: points, count: count)
            
            
            let location = CLLocationCoordinate2DMake(polyline.coordinate.latitude, polyline.coordinate.longitude)
            print(routes[0].bounds.northeast)
            
            
            
            let span = MKCoordinateSpan(latitudeDelta: routes[0].bounds.northeast.latitude - routes[0].bounds.southwest.latitude, longitudeDelta: routes[0].bounds.northeast.longitude - routes[0].bounds.southwest.longitude)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.mapView.setRegion(region, animated: true)
            
            self.mapView.addOverlay(polyline)
            
        })
        
        
    }

}

