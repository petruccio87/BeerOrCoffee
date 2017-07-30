//
//  ViewController.swift
//  BeerOrCoffee
//
//  Created by Petr Shibalov on 05.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit

import Alamofire
import RealmSwift
import SwiftyJSON



class TableViewController: UITableViewController {
    
    let api : Api = Api()
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil     // нотификация realm
    var searchType = "Bar"  // меняется через seque
    var lat: Double = 0
    var lng: Double = 0
    var classPlace : [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let backgroundImage = UIImage(named: "bg.png")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = imageView
        
        
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
 // ищем каждый раз
        
        print("1. start find places \(Thread.current)")
        print(self.api.findPlaces(type: self.searchType, lat: self.lat, lng: self.lng))
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
        
        
//------------------- Работает через реалм нотификацию -------------------
// ищем каждый раз
//        print(api.findPlaces(type: searchType, lat: lat, lng: lng))
 // загружаем все данные из базы
//  прекрасно работает, но нам надо сделать свою нотификацию вместо реалмовской
//        notificationToken = realm.addNotificationBlock {notification, realm in
//            self.classPlace = self.api.loadClassPlacesListDB()
//            self.tableView.reloadData()
//        }
//-----------------------------------------------------------------------
    
    }
    
    func refreshTableView() {
        self.classPlace = self.api.loadClassPlacesListDB()
        DispatchQueue.main.sync {
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classPlace.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = classPlace[indexPath.row].name
        if classPlace[indexPath.row].rating == "" {
            cell.detailTextLabel?.text = "Raiting: -"
        } else {
            cell.detailTextLabel?.text = "Raiting: " + classPlace[indexPath.row].rating
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.place = classPlace[indexPath.row]
            }
            
        }
    }
    
    
    
/*
    func findPlaces() {
        let apikey = "AIzaSyBzfEMMl1BGXGoLngcVuEdu2HvOGTMVT48"
        let latlng = "55.761704,37.620350"
        let radius = "150"
        let rankby = "distance"
        let placeType = "bar"
        let language = "ru"
        
        let urlByRadius = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+latlng+"&radius="+radius+"&opennow=true&type="+placeType+"&language="+language+"&key=" + apikey
        let urlByDistance = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+latlng+"&rankby="+rankby+"&opennow=true&type="+placeType+"&language="+language+"&key=" + apikey
        
        Alamofire.request(urlByDistance, method: .get).validate().responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                if json["status"].stringValue == "OK" {
                    cityList.remove(at: 0)
                    for (key,place):(String, JSON) in json["results"] {
                        print(key, " ", place["name"].stringValue)
                        cityList.append((name: place["name"].stringValue, rating: place["rating"].stringValue, priceLevel: place["price_level"].stringValue, latLng: place["geometry"]["location"]["lat"].stringValue+","+place["geometry"]["location"]["lng"].stringValue, address: place["vicinity"].stringValue))
                        print("     Rating: ", place["rating"].stringValue)
                        print("     Price Level: ", place["price_level"].stringValue)   // не везде есть
                        print("     LatLng: ", place["geometry"]["location"]["lat"].stringValue, ",", place["geometry"] ["location"]["lng"].stringValue)
                        print("     Адрес: ", place["vicinity"].stringValue)
                    }
                    print("Num of Res: \(json["results"].count)")
                    self.tableView.reloadData()
                }
                print("Json ResponseResult: \(json)")
            case .failure(let error):
                print(error)
            }
        }
    }
*/
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    deinit {
//        notificationToken?.stop()       //  включить когда используется реальмовская нотификация
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
    }
    
}

