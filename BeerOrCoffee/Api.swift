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


let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
let serialQueue = DispatchQueue(label: "serial_queue")
var timer: DispatchSourceTimer? // таймер для бэкграунда - чтобы не ждать слишком долго загрузки данных

private let _sharedApi = Api()

class Api {

    //    --------------------------------------------
    //    singltone
    
    class var sharedApi: Api {
        return _sharedApi
    }
    //    --------------------------------------------
    private var _placesData: [PlacesData] = []
    
    var placesData: [PlacesData] {
        var placesDataCopy: [PlacesData]!
        concurrentQueue.sync {
            placesDataCopy = self._placesData
//            print("self._placesData: \(self._placesData)")
        }
        
        return placesDataCopy
    }
    private var _favPlacesData: [FavoritsData] = []
    
    var favPlacesData: [FavoritsData] {
        var favPlacesDataCopy: [FavoritsData]!
        concurrentQueue.sync {
            favPlacesDataCopy = self._favPlacesData
        }
        
        return favPlacesDataCopy
    }
    private var _photoData: [PhotosData] = []
    
    var photoData: [PhotosData] {
        var photoDataCopy: [PhotosData]!
        concurrentQueue.sync {
            photoDataCopy = self._photoData
        }
        
        return photoDataCopy
    }
    //    --------------------------------------------
    //    data from DB
    func getPlacesDataFromDB() {
        let realm = try! Realm()
        self._placesData = Array(realm.objects(PlacesData.self))
    }
    func getFavPlacesDataFromDB() {
        let realm = try! Realm()
        self._favPlacesData = Array(realm.objects(FavoritsData.self).filter("favorit == true"))
        //        print(self._placesData)
    }
    func getPhotoDataFromDB(place_id: String) {
        let realm = try! Realm()
        print("getPhotoData - id - \(place_id)")
        self._photoData = Array(realm.objects(PhotosData.self).filter("place_id == %@", place_id))
    }

// памятка
//--------------------------------------------
//    fileprivate var _placeList: [Place] = []
//    
//    var placeList: [Place]? {
//        var placeListCopy: [Place]!
//        concurrentQueue.sync {
//            placeListCopy = self._placeList
//        }
//        return placeListCopy
//    }
//    
//    func resetPlaceList(){
//        concurrentQueue.sync {
//            _placeList = []
//        }
//    }
//
//    func getPlaceListFromDB() {
//        let realm = try! Realm()
//        self._placeList = Array(realm.objects(PlaceList))
//    }
    
    
    func findPlaces(type: String, lat: Double, lng: Double) {
        
        autoreleasepool{
        concurrentQueue.async {
       
// памятка
//        print("1. INSIDE start findplaces \(Thread.current)")
//        let ft = FilesTasks()       //  по сути не нужен. Просто задание с файлами в домашке
//        let filename = "searchResults.txt"
//        let dir = "/Documents"
//        var contentToFile = ""
//        ft.createFile(dirname: dir, filename: filename) //домашка с файлами - не нужно
        
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

        Alamofire.request(urlByDistance, method: .get).validate().responseJSON(queue: concurrentQueue) { response in
            switch response.result{
            case .success(let value):
                print("2. INSIDE Alomofire \(Thread.current)")
                
                let json = JSON(value)
                if json["status"].stringValue == "OK" {
                    var placeDataArray : [PlacesData] = []
                    for (key,place):(String, JSON) in json["results"] {
                        let placeData = PlacesData()
                        
//                        print(key, " ", place["name"].stringValue)
//                        print("     Rating: ", place["rating"].stringValue)
//                        print("     Price Level: ", place["price_level"].stringValue)   // не везде есть
//                        print("     LatLng: ", place["geometry"]["location"]["lat"].stringValue, ",", place["geometry"] ["location"]["lng"].stringValue)
//                        print("     Адрес: ", place["vicinity"].stringValue)
                        
                        concurrentQueue.async {
                            if Api.sharedApi.isFavorit(place_id: place["place_id"].stringValue) { // найденое заведение может уже быть в любимых - фото надо писать как fav
                                Api.sharedApi.findPlaceInfo(place_id: place["place_id"].stringValue, favorit: true)
                            } else {
                                Api.sharedApi.findPlaceInfo(place_id: place["place_id"].stringValue, favorit: false)
                            }
                        }
                        
                        placeData.place_name = place["name"].stringValue
                        placeData.place_id = place["place_id"].stringValue
                        placeData.place_icon = place["icon"].stringValue
                        placeData.raiting = place["rating"].stringValue
                        placeData.price_level = place["price_level"].stringValue
                        placeData.latLng = place["geometry"]["location"]["lat"].stringValue+","+place["geometry"]["location"]["lng"].stringValue
                        placeData.address = place["vicinity"].stringValue
                       // placeData.favorit = false
                       
                        placeDataArray.append(placeData)
//                        self.writePlaceToDB(data: placeData)      // когда добавляли по одному а не массивом
                        
                        if key == "0" {             // если приложение обновляется в фоне, то показывает local notification и сохраняет запись в userdefaults для today widget
                            let state: UIApplicationState = UIApplication.shared.applicationState
                            if state == .background {
                                if #available(iOS 10.0, *) {
                                    sendLocalNotification(name: place["name"].stringValue, raiting: place["rating"].stringValue)
                                } else {
                                    // Fallback on earlier versions
                                }
                                let defaults = UserDefaults(suiteName: "group.petruccio.BeerOrCoffee")
                                defaults?.set(place["name"].stringValue, forKey: "name")
                                defaults?.set(place["rating"].stringValue, forKey: "raiting")
                                defaults?.synchronize()
                            }
                            else if state == .active {
                                // foreground
                                let defaults = UserDefaults(suiteName: "group.petruccio.BeerOrCoffee")
                                defaults?.set(place["name"].stringValue, forKey: "name")
                                defaults?.set(place["rating"].stringValue, forKey: "raiting")
                                defaults?.synchronize()
                            }
                        }
                            
                        self.downloadIcon(downloadLink: place["icon"].stringValue, typeIcon: placeType)
//                        contentToFile += place["name"].stringValue+"\n"
                    
                    }
                    self.writePlaceToDB(data: placeDataArray)
                  //  print("Num of Res: \(json["results"].count)")
                    
//              дз про работу с файлами - в принципе не нужно.
//                    ft.makeContentOfFile(filename: dir+"/"+filename, content: contentToFile)
//                    ft.gzip(filename: dir+"/"+filename, deleteSource: true)
//                    ft.deleteFile(filename: dir+"/"+filename)
                    
                    load = true as AnyObject
                    

                }
                //print("Json ResponseResult: \(json)")
            case .failure(let error):
                print(error)
            }
            print("3. INSIDE Alomofire - the end \(Thread.current)")
            
        }
    }   // end concurentQueue
    }   // autorelease
    }
    
 // загружает инфо о заведении - пока что только ссылки на фотки
    func findPlaceInfo(place_id: String, favorit: Bool) {
//        Api.sharedApi.clearPhotosDB()
        autoreleasepool{
        concurrentQueue.async {
        
        let urlToFind = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=\(apikey)"
        Alamofire.request(urlToFind, method: .get).validate().responseJSON(queue: concurrentQueue) { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                if json["status"].stringValue == "OK" {
                    var photoDataArray : [PhotosData] = []
                    for (key,place):(String, JSON) in json["result"]["photos"] {
                        let photoData = PhotosData()
                        photoData.place_id = place_id
                        photoData.place_photo = place["photo_reference"].stringValue
                        photoData.favorit = favorit
                        
                        print("\(key) - photo")
                        
                        photoDataArray.append(photoData)
//                        self.writePhotoToDB(data: photoData)      // когда добавляли по одному а не массивом
   
                    }
                    self.writePhotoToDB(data: photoDataArray)
                }
            //print("Json ResponseResult: \(json)")
            case .failure(let error):
                print(error)
            }
        }
        }   // concurrent
        }      // autorelease
    }
    
    // загружает в любимые заведения указнные в firebase
    func loadDefaultVafInfo(place_id: String) {
        let realm = try! Realm()
        if realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place_id).count == 0 {
            autoreleasepool{
            concurrentQueue.async {
                Api.sharedApi.findPlaceInfo(place_id: place_id, favorit: true)
                let urlToFind = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place_id)&key=\(apikey)"
                Alamofire.request(urlToFind, method: .get).validate().responseJSON(queue: concurrentQueue) { response in
                    switch response.result{
                    case .success(let value):
                        let json = JSON(value)
                        if json["status"].stringValue == "OK" {
                            let placeData = FavoritsData()
                            placeData.place_name = json["result"]["name"].stringValue
                            placeData.place_id = json["result"]["place_id"].stringValue
                            placeData.place_icon = json["result"]["icon"].stringValue
                            placeData.raiting = json["result"]["rating"].stringValue
                            placeData.price_level = json["result"]["price_level"].stringValue
                            placeData.latLng = json["result"]["geometry"]["location"]["lat"].stringValue+","+json["result"]["geometry"]["location"]["lng"].stringValue
                            placeData.address = json["result"]["vicinity"].stringValue
                            placeData.favorit = true
                            //    print(placeData)
                            DispatchQueue.main.async {
                                try! realm.write {
                                    realm.add(placeData, update: true)
                                }
                            }
                        }
                    //print("Json ResponseResult: \(json)")
                    case .failure(let error):
                        print(error)
                    }
                }
            }   // concurrent
            }      // autorelease
        }
    }

    func writePlaceToDB(data: [PlacesData]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(data, update: true)
        }
//        DispatchQueue.main.async {
//                        Api.sharedApi.getPlacesDataFromDB()
//        }
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
//        print(". writePlaceToDB \(Thread.current)")
    }
    
    func writePhotoToDB(data: [PhotosData]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(data, update: true)
        }
        print(". writePhotoToDB \(Thread.current)")
    }
    
    func makeFavPhoto(place_id: String) {   // при добавлении заведения в любимые его фото надо отметить как любимые и наоборот
        let realm = try! Realm()
        let data = realm.objects(PhotosData.self).filter("place_id BEGINSWITH %@", place_id)
        var newdata : [PhotosData] = []
        for value in data {
            let tmp = PhotosData()
            tmp.place_id = value.place_id
            tmp.favorit = !value.favorit
            tmp.place_photo = value.place_photo
            newdata.append(tmp)
        }
        try! realm.write {
            realm.add(newdata, update: true)
        }
        print(". makeFavPhoto \(Thread.current)")
    }
    
    func writeIconToDB(icon: IconsData) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(icon, update: true)
        }
//        print(". writeIconToDB \(Thread.current)")
    }
    
    func clearResultsDB() {
        let realm = try! Realm()
        let removeData = realm.objects(PlacesData.self)
        try! realm.write {
            realm.delete(removeData)
        }
//        DispatchQueue.main.async {
//            Api.sharedApi.getPlacesDataFromDB()
//        }
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
        print(". clearResultsDB \(Thread.current)")
    }
    
    func clearPhotosDB() {
        let realm = try! Realm()
        let removeData = realm.objects(PhotosData.self).filter("favorit != true")
        try! realm.write {
            realm.delete(removeData)
        }
        print(". clearPhotosDB \(Thread.current)")
    }
    
// вариант для работы через класс, а не синглтон
// возвращает ВСЕ данные из базы
//    func loadClassPlacesListDB() -> [Place]  {
//        
//        let realm = try! Realm()
//        var classPlace : [Place] = []
//        let data = realm.objects(PlacesData.self)
//        for value in data {
//            let tmpPlace = Place()
//            tmpPlace.name = value.place_name
//            tmpPlace.place_id = value.place_id
//            tmpPlace.priceLevel = value.price_level
//            tmpPlace.rating = value.raiting
//            tmpPlace.latLng = value.latLng
//            tmpPlace.address = value.address
//            tmpPlace.favorite = value.favorit
//            tmpPlace.icon = value.place_icon
//            classPlace.append(tmpPlace)
//        }
//        return classPlace
//    }
    
// возвращает данные об Любимых метсах (favorits)
//    func loadClassFavPlacesListDB() -> [Place]  {
//        
//        let realm = try! Realm()
//        var classPlace : [Place] = []
//        let data = realm.objects(FavoritsData.self).filter("favorit == true")
//        for value in data {
//            let tmpPlace = Place()
//            tmpPlace.name = value.place_name
//            tmpPlace.place_id = value.place_id
//            tmpPlace.priceLevel = value.price_level
//            tmpPlace.rating = value.raiting
//            tmpPlace.latLng = value.latLng
//            tmpPlace.address = value.address
//            tmpPlace.favorite = value.favorit
//            tmpPlace.icon = value.place_icon
//            classPlace.append(tmpPlace)
//        }
//        return classPlace
//    }
    
// удаляет заведение из базы любимых
    func removePlaceFromDB(place_id: String) {
        let realm = try! Realm()
        let data = realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place_id)
        try! realm.write {
            realm.delete(data)
        }
    }
    
// чистит favorits от находящихся там заведения но со снятой отметкой fav
    func clearFavoritsDB() {
        let realm = try! Realm()
        let data = realm.objects(FavoritsData.self).filter("favorit == false")
        try! realm.write {
            realm.delete(data)
        }
    }
    
    func isFavorit(place_id: String) -> Bool{
        let realm = try! Realm()
        if realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@ AND favorit == true", place_id).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func makeFavorit(place_id: String) {
        makeFavPhoto(place_id: place_id)
        let realm = try! Realm()
        if realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place_id).count > 0 {
            if realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@ AND favorit == true", place_id).count > 0 {
                let data = realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place_id)
                let newdata = FavoritsData()
                newdata.place_name = data[0].place_name
                newdata.place_id = data[0].place_id
                newdata.place_icon = data[0].place_icon
                newdata.raiting = data[0].raiting
                newdata.price_level = data[0].price_level
                newdata.latLng = data[0].latLng
                newdata.address = data[0].address
                newdata.favorit = false
                try! realm.write {
                    realm.add(newdata, update: true)
                }
            } else {
                let data = realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place_id)
                let newdata = FavoritsData()
                newdata.place_name = data[0].place_name
                newdata.place_id = data[0].place_id
                newdata.place_icon = data[0].place_icon
                newdata.raiting = data[0].raiting
                newdata.price_level = data[0].price_level
                newdata.latLng = data[0].latLng
                newdata.address = data[0].address
                newdata.favorit = true
                try! realm.write {
                    realm.add(newdata, update: true)
                }
            }
        }else{
            let data = realm.objects(PlacesData.self).filter("place_id BEGINSWITH %@", place_id)
            let newdata = FavoritsData()
            newdata.place_name = data[0].place_name
            newdata.place_id = data[0].place_id
            newdata.place_icon = data[0].place_icon
            newdata.raiting = data[0].raiting
            newdata.price_level = data[0].price_level
            newdata.latLng = data[0].latLng
            newdata.address = data[0].address
            newdata.favorit = true
            try! realm.write {
                realm.add(newdata, update: true)
            }
        }
    }
    
// скачивает иконку для типа заведения
    func downloadIcon(downloadLink: String, typeIcon: String) {
        //        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory) // не перезаписывает файл
        let newName = downloadLink.components(separatedBy: "/")
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(newName.last!)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(downloadLink, to: destination)
            .downloadProgress { progress in
//                print("Download Progress: \(progress.fractionCompleted) --- \(Thread.current)")
            }
            .responseData(queue: concurrentQueue) { response in
                if response.result.value != nil {
//                    print("Downloaded file \(response.destinationURL?.path) successfully")
                    let icon = IconsData()
                    icon.icon_type = typeIcon
                    icon.icon_url = downloadLink
                    icon.icon_local = newName.last!
                    
                    self.writeIconToDB(icon: icon)
                }
        }
    }
    
    func loadPhoto(url: String) -> UIImage {
        var image = UIImage()
        var imageData: Data?
        let tmpurl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(url)&key=\(apikey)"
        let url1 = URL(string: tmpurl)
        concurrentQueue.sync() {            // нельзя async - вернет пустоту
            print("1. start LOAD image\(Thread.current)")
            do {
                imageData = try  Data(contentsOf: url1!)
//                print("2. dataload \(imageData)")
            } catch{
                print("error")
            }
            if let value =  imageData{
                image = UIImage(data: value)!
//                print("3. image \(image)")
            }
            
        }
        print("4. return END IMAGE \(image)")
        return image
    }
    
    // скачивает новую картинку на фон
    func downloadNewBG(height: String, width: String) {
        //        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory) // не перезаписывает файл
        let newName = "newbg.jpeg"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(newName)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let downloadLink = "https://unsplash.it/"+width+"/"+height+"/?random&gravity=west"
        Alamofire.download(downloadLink, to: destination)
            .downloadProgress { progress in
                //                print("Download Progress: \(progress.fractionCompleted) --- \(Thread.current)")
            }
            .responseData(queue: concurrentQueue) { response in
                if response.result.value != nil {
                    print("Downloaded newBG \(String(describing: response.destinationURL?.path)) successfully")
                }
        }
    }

}




// проверка запускалась ли программа раньше, сейчас смысла нет, но на память оставим
var load: AnyObject? {
    get {
        return UserDefaults.standard.object(forKey: "flag") as AnyObject?
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "flag")
        UserDefaults.standard.synchronize()
    }
    
}

// время последнего обновления в бэкграунде
var lastUpdate: Date? {
    get {
        return UserDefaults.standard.object(forKey: "Last Update") as? Date
    }
    set {
        UserDefaults.standard.setValue(Date(), forKey: "Last Update")
    }
}

