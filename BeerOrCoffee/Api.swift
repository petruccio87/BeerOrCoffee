//
//  Api.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import Foundation

import Alamofire
import RealmSwift
import SwiftyJSON

class Api {             // пока не используется, функция поиска в классе TableViewController
    
    func findPlaces() {
        let apikey = "AIzaSyCzZGMY1lCgjzX1aVAEGXluHrKS19YDr4w"
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
                    for (key,place):(String, JSON) in json["results"] {
                        print(key, " ", place["name"].stringValue)
                        //  cityList.append(place["name"].stringValue)
                        print("     Rating: ", place["rating"].stringValue)
                        print("     Price Level: ", place["price_level"].stringValue)   // не везде есть
                        print("     LatLng: ", place["geometry"]["location"]["lat"].stringValue, ",", place["geometry"] ["location"]["lng"].stringValue)
                        print("     Адрес: ", place["vicinity"].stringValue)
                    }
                    print("Num of Res: \(json["results"].count)")
                    //      TableViewController.tableView.reloadData()
                }
            //print("Json ResponseResult: \(json)")
            case .failure(let error):
                print(error)
            }
        }
    }
}
