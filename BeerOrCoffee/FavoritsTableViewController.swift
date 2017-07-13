//
//  FavoritsTableViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//


import UIKit

import Alamofire
import RealmSwift
import SwiftyJSON



class FavoritsTableViewController: UITableViewController {
    
    let api : Api = Api()
    var cityList = [(name: "None", rating: "None", priceLevel: "None", latLng: "None", address: "None", favorit: false, place_id: "None")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        //print(api.findPlaces())
        
        if load == nil {
            api.findPlaces()
        } else {
            cityList = api.loadFavPlacesListDB()
        }
        
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
                destinationVC.place_id = cityList[indexPath.row].place_id
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

