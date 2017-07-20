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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameLabel : UILabel = self.view.viewWithTag(1) as! UILabel
        let ratingLabel : UILabel = self.view.viewWithTag(2) as! UILabel
        let priceLevelLabel : UILabel = self.view.viewWithTag(3) as! UILabel
        let latLngLabel : UILabel = self.view.viewWithTag(4) as! UILabel
        let addressLabel : UILabel = self.view.viewWithTag(5) as! UILabel
        // Do any additional setup after loading the view.
        nameLabel.text = place.name
        ratingLabel.text = place.rating
        priceLevelLabel.text = place.priceLevel
        latLngLabel.text = place.latLng
        addressLabel.text = place.address
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favorit(_ sender: UIButton) {
        let realm = try! Realm()
  // не хорошо конечно дублировать код, но не получается один раз определить data т.к. она то favoritsData то placesData, а преобразовывать их друг в друга не получается
        if realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place.place_id).count > 0 {
             let data = realm.objects(FavoritsData.self).filter("place_id BEGINSWITH %@", place.place_id)
            let newdata = FavoritsData()
            newdata.place_name = data[0].place_name
            newdata.place_id = data[0].place_id
            newdata.place_icon = data[0].place_icon
            newdata.raiting = data[0].raiting
            newdata.price_level = data[0].price_level
            newdata.latLng = data[0].latLng
            newdata.address = data[0].address
            newdata.favorit = !data[0].favorit
            try! realm.write {
                realm.add(newdata, update: true)
            }
        } else {
             let data = realm.objects(PlacesData.self).filter("place_id BEGINSWITH %@", place.place_id)
            let newdata = FavoritsData()
            newdata.place_name = data[0].place_name
            newdata.place_id = data[0].place_id
            newdata.place_icon = data[0].place_icon
            newdata.raiting = data[0].raiting
            newdata.price_level = data[0].price_level
            newdata.latLng = data[0].latLng
            newdata.address = data[0].address
            newdata.favorit = !data[0].favorit
            try! realm.write {
                realm.add(newdata, update: true)
            }
            
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
