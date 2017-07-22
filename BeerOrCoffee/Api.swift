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
    
    func findPlaces(type: String, lat: Double, lng: Double) {
        
        let realm = try! Realm()
        
        let ft = FilesTasks()       //  по сути не нужен. Просто задание с файлами в домашке
        let filename = "searchResults.txt"
        let dir = "/Documents"
        var contentToFile = ""
        ft.createFile(dirname: dir, filename: filename) //домашка с файлами - не нужно
        
        //let latlng = "55.761704,37.620350"
        let latlng = String(lat) + "," + String(lng)
        let radius = "150"
        let rankby = "distance"
        var placeType = ""
        if type == "Bar" {
             placeType = "bar"
        } else if type == "Cafe" {
             placeType = "cafe"
        } else {
             placeType = "bar"
        }
        let language = "ru"
        
        let urlByRadius = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+latlng+"&radius="+radius+"&opennow=true&type="+placeType+"&language="+language+"&key=" + apikey
        let urlByDistance = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+latlng+"&rankby="+rankby+"&opennow=true&type="+placeType+"&language="+language+"&key=" + apikey
        
        Alamofire.request(urlByDistance, method: .get).validate().responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                if json["status"].stringValue == "OK" {
                    
                    let removeData = realm.objects(PlacesData.self)     // очищаем результаты поиска перед запоминанием новых результатов поиска
                    try! realm.write {
                        realm.delete(removeData)
                    }
                    
                    
                    for (key,place):(String, JSON) in json["results"] {
                        let placeData = PlacesData()
                        
                        print(key, " ", place["name"].stringValue)
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
                        
                        self.downloadIcon(downloadLink: place["icon"].stringValue, typeIcon: placeType)
                        contentToFile += place["name"].stringValue+"\n"
                    
                    }
                  //  print("Num of Res: \(json["results"].count)")
                    
                    ft.makeContentOfFile(filename: dir+"/"+filename, content: contentToFile)
                    ft.gzip(filename: dir+"/"+filename, deleteSource: true)
                    //ft.deleteFile(filename: dir+"/"+filename)
                    
                    load = true as AnyObject
                    

                }
                //print("Json ResponseResult: \(json)")
            case .failure(let error):
                print(error)
            }
        }
    }
    

// возвращает ВСЕ данные из базы
    func loadClassPlacesListDB() -> [Place]  {
        
        let realm = try! Realm()
        var classPlace : [Place] = []
        let data = realm.objects(PlacesData.self)
        for value in data {
            let tmpPlace = Place()
            tmpPlace.name = value.place_name
            tmpPlace.place_id = value.place_id
            tmpPlace.priceLevel = value.price_level
            tmpPlace.rating = value.raiting
            tmpPlace.latLng = value.latLng
            tmpPlace.address = value.address
            tmpPlace.favorite = value.favorit
            tmpPlace.icon = value.place_icon
            classPlace.append(tmpPlace)
        }
        return classPlace
    }
    
// возвращает данные об Любимых метсах (favorits)
    func loadClassFavPlacesListDB() -> [Place]  {
        
        let realm = try! Realm()
        var classPlace : [Place] = []
        let data = realm.objects(FavoritsData.self).filter("favorit == true")
        for value in data {
            let tmpPlace = Place()
            tmpPlace.name = value.place_name
            tmpPlace.place_id = value.place_id
            tmpPlace.priceLevel = value.price_level
            tmpPlace.rating = value.raiting
            tmpPlace.latLng = value.latLng
            tmpPlace.address = value.address
            tmpPlace.favorite = value.favorit
            tmpPlace.icon = value.place_icon
            classPlace.append(tmpPlace)
        }
        return classPlace
    }
    
// удаляет заведение из базы любимых
    func removePlaceFromDB(place_id: String) {
        let realm = try! Realm()
        let data = realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place_id)
        try! realm.write {
            realm.delete(data)
        }
        
    }
    
    func isFavorit(place_id: String) -> Bool{
        let realm = try! Realm()
        if realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place_id).count > 0 {
            return true
        } else {
            return false
        }
    }
    
// скачивает иконку для типа заведения
    func downloadIcon(downloadLink: String, typeIcon: String) {
        let realm = try! Realm()
        //        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory) // не перезаписывает файл
        let newName = downloadLink.components(separatedBy: "/")
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(newName.last!)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(downloadLink, to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData { response in
                if response.result.value != nil {
//                    print("Downloaded file \(response.destinationURL?.path) successfully")
                    let icon = IconsData()
                    icon.icon_type = typeIcon
                    icon.icon_url = downloadLink
                    icon.icon_local = newName.last!
                    try! realm.write {
//                        print(icon)
                        realm.add(icon, update: true)
                    }
                }
        }
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
