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
    
    
    var place = Place()
    let api : Api = Api()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameLabel : UILabel = self.view.viewWithTag(1) as! UILabel
        let ratingLabel : UILabel = self.view.viewWithTag(2) as! UILabel
        let priceLevelLabel : UILabel = self.view.viewWithTag(3) as! UILabel
        let latLngLabel : UILabel = self.view.viewWithTag(4) as! UILabel
        let addressLabel : UILabel = self.view.viewWithTag(5) as! UILabel
        let favButton : UIButton = self.view.viewWithTag(6) as! UIButton
        // Do any additional setup after loading the view.
        nameLabel.text = place.name
        ratingLabel.text = place.rating
        priceLevelLabel.text = place.priceLevel
        latLngLabel.text = place.latLng
        addressLabel.text = place.address
        if api.isFavorit(place_id: place.place_id) {
            let favImage = UIImage(named: "star_true.png")
            favButton.setImage(favImage, for: .normal)
        } else {
            let favImage = UIImage(named: "star_false.png")
            favButton.setImage(favImage, for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// кнопка favorit- добавляет в базу любимых, если места там нет, и удаляет из базы любимых, если оно там есть.
    @IBAction func favorit(_ sender: UIButton) {
        let realm = try! Realm()
        
        if realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place.place_id).count > 0 {
            let data = realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place.place_id)
            if data[0].favorit {                   // если есть в favorits то удаляем из базы
                api.removePlaceFromDB(place_id: place.place_id)
                place.favorite = false           // для изменения картинки звезды
                viewDidLoad()
            }
        } else {
            let newdata = FavoritsData()        // если нет в favorits то добавляем в базу
            newdata.place_name = place.name
            newdata.place_id = place.place_id
            newdata.place_icon = place.icon
            newdata.raiting = place.rating
            newdata.price_level = place.priceLevel
            newdata.latLng = place.latLng
            newdata.address = place.address
            newdata.favorit = true
            try! realm.write {
                realm.add(newdata, update: true)
            }
            place.favorite = true           // для изменения картинки звезды
            viewDidLoad()
    }
        
        
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
