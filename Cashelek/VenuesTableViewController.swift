//
//  VenuesTableViewController.swift
//  Cashelek
//
//  Created by Rustam Gradov on 10/04/2019.
//  Copyright © 2019 Rustam Gradov. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import AlamofireImage

// энум - просто для удобства вызова
enum Constants {
    static let FoursquareID = "HYIJPMWKUCHP0OAD4QG2R21XJLLVTWIHASBJGPQ2M342IFAM"
    static let FoursquareSecret = "04MUOTIS5QVIN2YJZL55LGN4FXRRZTL1XXGWFZGBUBMZ4JOK"
}

protocol VenuesTableViewControllerDelegate: class {
    func venueSelected(_ venue: Venue)
}

class VenuesTableViewController: UITableViewController {
    
    @IBOutlet var tableVenues: UITableView!
    
    weak var delegate: VenuesTableViewControllerDelegate?
    
    var venues: [Venue] = []
    
    let locationManager = CLLocationManager()
    
    //создаю константу очереди для загрузки картинок не в основном потоке
//    let imageQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //проверяю текущий статус авторизации доступа к локации
        if CLLocationManager.authorizationStatus() == .notDetermined {
            //если еще не определен, то запрашиваю доступ
            locationManager.requestWhenInUseAuthorization()
        } else {
            //или пытаюсь получить локацию
            locationManager.requestLocation()
        }
        let refreshControl = UIRefreshControl()
        //добавляю connection как action
        refreshControl.addTarget(self, action: #selector(refreshVenues), for: .valueChanged)
        //работает только для UITableViewController под-классов
        self.refreshControl = refreshControl
        //если у меня просто UITableView + UIViewController
        //tableView.subView(refreshControl)
        
    }
    //потянуть вниз и обновить список venues
    @objc func refreshVenues() {
        locationManager.requestLocation()
    }
    
    
    
    //мой метод, который берет данные с сервиса 4square, формирует список параметров
    func fetchVenues(at location: CLLocation) {
        
        let url = "https://api.foursquare.com/v2/venues/search"
        
        let parameters = [
            "client_id": Constants.FoursquareID,
            "client_secret": Constants.FoursquareSecret,
            "v": "20160914",
            "ll": "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        ]
        //делаю запрос с параметрами HTTP GET запроса
        Alamofire.request(url, parameters: parameters).responseJSON { (response) in
            //закончил обновлять страницу с venues
            self.refreshControl?.endRefreshing()
            //value - это может быть JSON  с ответом сервера
            if let value = response.value {
                //обращаюсь к json
                let json = JSON(value)
                //затем к его свойствам, а в свойстве еще свойство
                //т.к. venue - массив значений, через arrayValue подбираюсь к нему
                let jsonArray = json["response"]["venues"].arrayValue
                //создаю массив куда сложу конвертированные в Venue объекты из json
                var results: [Venue] = []
                //перебираю все json объекты
                for object in jsonArray {
                    //создаю объект venue
                    let venue = Venue()
                    venue.id = object["id"].stringValue
                    venue.name = object["name"].stringValue
                    venue.address = object["location"]["address"].stringValue
                    venue.latitude = object["location"]["lat"].doubleValue
                    venue.longitude = object["location"]["lng"].doubleValue
                    venue.distance = object["location"]["distance"].intValue
                    
                    //получаю данные об иконках к категориям по адресу
                    if let category = object["categories"].array?.first {
                        let prefix = category["icon"]["prefix"].stringValue
                        let suffix  = category["icon"]["suffix"].stringValue
                        let string = "\(prefix)bg_64\(suffix)"
                        venue.iconURL = URL(string: string)
                    }
                    //добавляю его в массив
                    results.append(venue)
                }
                //сортировка мест по расстоянию перед тем как записывать
                //в веньюс.
                //нужно вернуть Bool который ответит на вопрос
                //нужно ли $0 поставить перед $1
                results.sort(by: { $0.distance! < $1.distance! })
                self.venues = results
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableViewCell", for: indexPath) as! VenueTableViewCell
        let venue = venues[indexPath.row]
        
        cell.labelName.text = venue.name
        cell.labelAddress.text = venue.address
        //        cell.labelDistance.text = "\(venue.distance ?? 0) м."
        if let distance = venue.distance {
            cell.labelDistance.text = "\(distance) м."
        } else {
            cell.labelDistance.text = ""
        }
        
        if let iconURL = venue.iconURL {
            cell.imageCategories.af_setImage(withURL: iconURL)
        } else {
            cell.imageCategories.image = nil
        }
       //этот код если грузить картинки самому, без AlomofireImage
//        if let iconURL = venue.iconURL {
//            //достаю картинку по адресу
//            imageQueue.addOperation ({
//                //здесь загрузка произошла НЕ в главном потоке
//                let data = try! Data(contentsOf: iconURL)
//                let image = UIImage(data: data)
//                //а тут доступ к главному потоку, в котором присваиваю картинки
//                OperationQueue.main.addOperation ({
//                    cell.imageCategories.image = image
//                })
//            })
//
//        } else {
//            //TODO: find default pic
//            cell.imageCategories.image = nil
//        }
        return cell
    }
    //Методы делагата
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //снять выделение с ячейки
        tableView.deselectRow(at: indexPath, animated: true)
        
        let venue = venues[indexPath.row]
        print(venue)
        
        delegate?.venueSelected(venue)
    }
    
}

//Использую расширение, чтобы не плодить дофига кода в классе
extension VenuesTableViewController: CLLocationManagerDelegate {
    //метод вызовется сразу, как только скажу locationManager-у,
    //что я его delegate, а также когда он разрешит/запретит
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied:
            print("user denied location") // need to present alert
        case .restricted:
            print("user turned off location completely") // need to present alert
        }
    }
    //вызывается когда locationManager определил локацию пользователя
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        print("user is found at \(location)")
        
        fetchVenues(at: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to acquire location with \(error)")
    }
    
}

