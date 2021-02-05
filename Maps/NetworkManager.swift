//
//  NetworkManager.swift
//  Maps
//
//  Created by user177273 on 2/1/21.
//  Copyright © 2021 alumnos. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import GoogleMaps
import GooglePlaces

class NetworkManager: GoogleDirectionAPI {
    
    let APIKey = "AIzaSyDObYtXRXU9ZgWaOI_gMea_4nVtzJeonRw"
    
    static var shared: NetworkManager = NetworkManager()
    
    func getRoute(origin: String, destination: String, completion: @escaping (MKPolyline) -> Void) {
       
        let scheme = "https"
        let host = "maps.googleapis.com"
        let path = "/maps/api/directions/json"
        let queryOrigin = URLQueryItem(name: "origin", value: origin)
        let queryDestination = URLQueryItem(name: "destination", value: destination)
        let queryAPIKey = URLQueryItem(name: "key", value: APIKey)
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = [queryOrigin, queryDestination, queryAPIKey]
        
        if let url = urlComponents.url {
            
            AF.request(url)
                .validate()//Checks is return HTTPstatus code in 200-299
                .responseDecodable(of: RouteRS.self) { (response) in
                    guard let routeRS = response.value else { return }
                    let path = GMSPath.init(fromEncodedPath: routeRS.routes[0].overviewPolyline.points)
                    var points: [CLLocationCoordinate2D] = []
                    
                    for index in 0...(path?.count())!{
                        points.append((path?.coordinate(at: index))!)
                    }
                    
                    
                    let count = (points.count)-1
                    let polyline = MKPolyline(coordinates: points, count: count)
                    
                    completion(polyline)
                }
        }
    }
}

protocol GoogleDirectionAPI {
    
    func getRoute(origin: String, destination: String, completion: @escaping (MKPolyline)-> Void)
    
}
