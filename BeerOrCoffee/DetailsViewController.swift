//
//  DetailsViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//


import UIKit
import RealmSwift
import GoogleMaps

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
//    var mapView:GMSMapView?
    
    
//    var place = Place()
    var index: Int =  -1
    var from = "fromDetails"  // fromDetails or fromFaforits
    var markerLatLng : [String] = []
    var place_id : String = ""
    var markerTitle : String = ""
    var markerSnippet : String = ""
//    let api : Api = Api()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameLabel : UILabel = self.view.viewWithTag(1) as! UILabel
        let ratingLabel : UILabel = self.view.viewWithTag(2) as! UILabel
        let priceLevelLabel : UILabel = self.view.viewWithTag(3) as! UILabel
        let latLngLabel : UILabel = self.view.viewWithTag(4) as! UILabel
        let addressLabel : UILabel = self.view.viewWithTag(5) as! UILabel
        let favButton : UIButton = self.view.viewWithTag(6) as! UIButton
        // Do any additional setup after loading the view.
        
        
        if from == "fromDetails"{
            nameLabel.text = Api.sharedApi.placesData[index].place_name
            ratingLabel.text = Api.sharedApi.placesData[index].raiting
            priceLevelLabel.text = Api.sharedApi.placesData[index].price_level
            latLngLabel.text = Api.sharedApi.placesData[index].latLng
            addressLabel.text = Api.sharedApi.placesData[index].address
            markerLatLng = Api.sharedApi.placesData[index].latLng.components(separatedBy: ",")
            markerTitle = Api.sharedApi.placesData[index].place_name
            markerSnippet = Api.sharedApi.placesData[index].address
            place_id = Api.sharedApi.placesData[index].place_id
        } else if from == "fromFavorits" {
            nameLabel.text = Api.sharedApi.favPlacesData[index].place_name
            ratingLabel.text = Api.sharedApi.favPlacesData[index].raiting
            priceLevelLabel.text = Api.sharedApi.favPlacesData[index].price_level
            latLngLabel.text = Api.sharedApi.favPlacesData[index].latLng
            addressLabel.text = Api.sharedApi.favPlacesData[index].address
            markerLatLng = Api.sharedApi.favPlacesData[index].latLng.components(separatedBy: ",")
            markerTitle = Api.sharedApi.favPlacesData[index].place_name
            markerSnippet = Api.sharedApi.favPlacesData[index].address
            place_id = Api.sharedApi.favPlacesData[index].place_id
        }
        
        if Api.sharedApi.isFavorit(place_id: place_id) {
            //        if Api.sharedApi.placesData[index].favorit {
            let favImage = UIImage(named: "star_true.png")
            favButton.setImage(favImage, for: .normal)
        } else {
            let favImage = UIImage(named: "star_false.png")
            favButton.setImage(favImage, for: .normal)
        }
        mapView.camera = GMSCameraPosition.camera(withLatitude: Double(markerLatLng[0])!, longitude: Double(markerLatLng[1])!, zoom: 15.0)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(markerLatLng[0])!, longitude: Double(markerLatLng[1])!)
        marker.title = markerTitle
        marker.snippet = markerSnippet
        marker.map = mapView
        mapView.selectedMarker = marker // открывает описание маркера
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
//        let iconName = place.icon.components(separatedBy: "/")
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let iconURL = documentsURL.appendingPathComponent(iconName.last!)
//        marker.icon = UIImage(named: iconURL.path)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// кнопка favorit- добавляет в базу любимых, если заведения там нет, и удаляет из базы любимых, если оно там есть.
    @IBAction func favorit(_ sender: UIButton) {
//        Api.sharedApi.makeFavorit(place_id: Api.sharedApi.placesData[index].place_id)
        Api.sharedApi.makeFavorit(place_id: place_id)
        if from == "fromDetails" {
            viewDidLoad()
        } else if from == "fromFavorits" {
            let favButton : UIButton = self.view.viewWithTag(6) as! UIButton
            if Api.sharedApi.isFavorit(place_id: place_id) {
                //        if Api.sharedApi.placesData[index].favorit {
                let favImage = UIImage(named: "star_true.png")
                favButton.setImage(favImage, for: .normal)
            } else {
                let favImage = UIImage(named: "star_false.png")
                favButton.setImage(favImage, for: .normal)
            }
        }
//        let realm = try! Realm()
//        
//        if realm.objects(PlacesData.self).filter("place_id BEGINSWITH %@", Api.sharedApi.placesData[index].place_id).count > 0 {
//            let data = realm.objects(PlacesData.self).filter("place_id BEGINSWITH %@", Api.sharedApi.placesData[index].place_id)
//            if data[0].favorit {                   // если есть в favorits то удаляем из базы
////                Api.sharedApi.removePlaceFromDB(place_id: Api.sharedApi.placesData[index].place_id)
//                Api.sharedApi.placesData[index].favorit = false           // для изменения картинки звезды
//                viewDidLoad()
//            }
//        } else {
//            let newdata = FavoritsData()        // если нет в favorits то добавляем в базу
//            newdata.place_name = Api.sharedApi.placesData[index].place_name
//            newdata.place_id = Api.sharedApi.placesData[index].place_id
//            newdata.place_icon = Api.sharedApi.placesData[index].place_icon
//            newdata.raiting = Api.sharedApi.placesData[index].raiting
//            newdata.price_level = Api.sharedApi.placesData[index].price_level
//            newdata.latLng = Api.sharedApi.placesData[index].latLng
//            newdata.address = Api.sharedApi.placesData[index].address
//            newdata.favorit = true
//            try! realm.write {
//                realm.add(newdata, update: true)
//            }
//            Api.sharedApi.placesData[index].favorit = true           // для изменения картинки звезды
//            viewDidLoad()
//    }
        
        
        let alert = UIAlertController(title: "Alert", message: "test Alert", preferredStyle: .actionSheet)
        let actionOK = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
    }
    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
