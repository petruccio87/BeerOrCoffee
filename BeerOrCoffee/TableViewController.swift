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

var cityList = [(name: "None", rating: "None", priceLevel: "None", latLng: "None", address: "None")]

class TableViewController: UITableViewController {
    
    // let api : Api = Api()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //print(api.findPlaces())
        findPlaces()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cityList[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.name = cityList[indexPath.row].name
                destinationVC.rating = cityList[indexPath.row].rating
                destinationVC.priceLevel = cityList[indexPath.row].priceLevel
                destinationVC.latLng = cityList[indexPath.row].latLng
                destinationVC.address = cityList[indexPath.row].address
            }
            
        }
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

