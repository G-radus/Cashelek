//
//  MapViewController.swift
//  Cashelek
//
//  Created by Rustam Gradov on 16/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //данные беру из карт гугл, примерно
        let coordinate = CLLocationCoordinate2D(latitude: 55.7447382, longitude: 37.6266221)
        //настраиваю, что мы будем видеть при открытии карт
        let position = GMSCameraPosition(target: coordinate, zoom: 12)
        //передаю в объектив карт
        mapView.camera = position
        //показать позицию пользователя
        mapView.isMyLocationEnabled = true
        
    }
    //вызывается каждый раз, когда захожу на экран
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadMap()
    }
    
    func reloadMap() {
        //очистить старые маркеры
        mapView.clear()
        let venues = Venue.loadAllVenues()
        //добавить новые
        for venue in venues {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
            marker.title = venue.name
            marker.snippet = venue.address
            //добавляю маркер на карту
            marker.map = mapView
        }
    }
}
