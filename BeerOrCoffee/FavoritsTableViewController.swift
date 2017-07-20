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
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    
    var classPlace : [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        if load == nil {
//     api.findPlaces()      //если еще не запускались, то и любимых мест нет
        } else {
            classPlace = api.loadClassFavPlacesListDB()
        }
        
        notificationToken = realm.addNotificationBlock {notification, realm in
            self.classPlace = self.api.loadClassFavPlacesListDB()
            self.tableView.reloadData()
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if classPlace.count == 0 {      // заглушка - тут надо как-то показывать сообщение вместо пустой таблицы
            let tmpPlace = Place()
            tmpPlace.name = "So far there is Nothing"
            tmpPlace.place_id = ""
            tmpPlace.priceLevel = ""
            tmpPlace.rating = ""
            tmpPlace.latLng = ""
            tmpPlace.address = ""
            tmpPlace.favorite = false
            tmpPlace.icon = ""
            classPlace.append(tmpPlace)
            return 1
        }
        return classPlace.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = classPlace[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.place = classPlace[indexPath.row]
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        notificationToken?.stop()
    }
    
}

