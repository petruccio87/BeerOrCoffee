//
//  DetailsViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//


import UIKit
import RealmSwift

class DetailsViewController: UIViewController {
    
    
    
    var name : String = ""
    var rating : String = ""
    var priceLevel : String = ""
    var latLng : String = ""
    var address : String = ""
    var favorite : Bool = false
    var place_id : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameLabel : UILabel = self.view.viewWithTag(1) as! UILabel
        let ratingLabel : UILabel = self.view.viewWithTag(2) as! UILabel
        let priceLevelLabel : UILabel = self.view.viewWithTag(3) as! UILabel
        let latLngLabel : UILabel = self.view.viewWithTag(4) as! UILabel
        let addressLabel : UILabel = self.view.viewWithTag(5) as! UILabel
        // Do any additional setup after loading the view.
        nameLabel.text = name
        ratingLabel.text = rating
        priceLevelLabel.text = priceLevel
        latLngLabel.text = latLng
        addressLabel.text = address
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favorit(_ sender: UIButton) {
        let realm = try! Realm()
        let data = realm.objects(PlacesData.self).filter("place_id BEGINSWITH %@", place_id)
        let newdata = PlacesData()
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
    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
