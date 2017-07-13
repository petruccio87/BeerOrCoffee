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
        
        let realm = try! Realm()
        
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
  //                  cityList.remove(at: 0)
                    
                    for (key,place):(String, JSON) in json["results"] {
                        let placeData = PlacesData()
                        
                        print(key, " ", place["name"].stringValue)
  //                      cityList.append((name: place["name"].stringValue, rating: place["rating"].stringValue, priceLevel: place["price_level"].stringValue, latLng: place["geometry"]["location"]["lat"].stringValue+","+place["geometry"]["location"]["lng"].stringValue, address: place["vicinity"].stringValue))
                        print("     Rating: ", place["rating"].stringValue)
                        print("     Price Level: ", place["price_level"].stringValue)   // не везде есть
                        print("     LatLng: ", place["geometry"]["location"]["lat"].stringValue, ",", place["geometry"] ["location"]["lng"].stringValue)
                        print("     Адрес: ", place["vicinity"].stringValue)
                        
                        placeData.place_name = place["name"].stringValue
                        placeData.place_id = place["place_id"].stringValue
                        placeData.place_icon = place["icon"].stringValue
                        placeData.raiting = place["rating"].stringValue
                        placeData.price_level = place["price_level"].stringValue
                        placeData.latLng = place["geometry"]["location"]["lat"].stringValue+","+place["geometry"]["location"]["lng"].stringValue
                        placeData.address = place["vicinity"].stringValue
                       // placeData.favorit = false
                        
                        try! realm.write {
                            print(placeData)
                            realm.add(placeData, update: true)
                        }
                    
                    }
                  //  print("Num of Res: \(json["results"].count)")
                    
                    load = true as AnyObject
                    

                }
                //print("Json ResponseResult: \(json)")
            case .failure(let error):
                print(error)
            }
        }
    }
    

// возвращает ВСЕ данные из базы
    func loadPlacesListDB() -> [(name: String, rating: String, priceLevel: String, latLng: String, address: String, favorit: Bool, place_id: String)]  {
        let realm = try! Realm()
        var cityList: [(name: String, rating: String, priceLevel: String, latLng:  String, address: String, favorit: Bool, place_id: String)] = []
        let data = realm.objects(PlacesData.self)
        
        for value in data {
            cityList.append((name: value.place_name, rating: value.raiting, priceLevel: value.price_level, latLng: value.latLng, address: value.address, favorit: value.favorit, place_id: value.place_id ))
        }
        
        return cityList
    }
    
// возвращает данные об Любимых метсах (favorits)
    func loadFavPlacesListDB() -> [(name: String, rating: String, priceLevel: String, latLng: String, address: String, favorit: Bool, place_id: String)]  {
        let realm = try! Realm()
        var cityList: [(name: String, rating: String, priceLevel: String, latLng:  String, address: String, favorit: Bool, place_id: String)] = []
        let data = realm.objects(PlacesData.self).filter("favorit == true")
        
        for value in data {
            cityList.append((name: value.place_name, rating: value.raiting, priceLevel: value.price_level, latLng: value.latLng, address: value.address, favorit: value.favorit, place_id: value.place_id ))
        }
        
        return cityList
    }
}


// проверка запускалась ли программа раньше
var load: AnyObject? {
    get {
        return UserDefaults.standard.object(forKey: "flag") as AnyObject?
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "flag")
        UserDefaults.standard.synchronize()
    }
}
