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
    
//    let api : Api = Api()
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    
//    var classPlace : [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let backgroundImage = UIImage(named: "bg.png")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        self.tableView.backgroundView = imageView
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
        
        if load == nil {
//     api.findPlaces()      //если еще не запускались, то и любимых мест нет
        } else {
//            classPlace = api.loadClassFavPlacesListDB()
            Api.sharedApi.getFavPlacesDataFromDB()
        }
        
        notificationToken = realm.addNotificationBlock {notification, realm in
//            self.classPlace = self.api.loadClassFavPlacesListDB()
            Api.sharedApi.getFavPlacesDataFromDB()
            self.tableView.reloadData()
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if Api.sharedApi.favPlacesData.count == 0 {      // заглушка - тут надо как-то показывать сообщение вместо пустой таблицы
//            let tmpPlace = Place()
//            tmpPlace.name = "So far there is Nothing"
//            tmpPlace.place_id = ""
//            tmpPlace.priceLevel = ""
//            tmpPlace.rating = ""
//            tmpPlace.latLng = ""
//            tmpPlace.address = ""
//            tmpPlace.favorite = false
//            tmpPlace.icon = ""
//            classPlace.append(tmpPlace)
//            return 1
//        }
//        return classPlace.count
        return Api.sharedApi.favPlacesData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Api.sharedApi.favPlacesData[indexPath.row].place_name
        if Api.sharedApi.favPlacesData[indexPath.row].raiting == "" {
            cell.detailTextLabel?.text = "Raiting: -"
        } else {
//            cell.detailTextLabel?.text = "Raiting: " + classPlace[indexPath.row].rating
            cell.detailTextLabel?.text = "Raiting: " + Api.sharedApi.favPlacesData[indexPath.row].raiting
        }
        cell.backgroundColor = .clear
        return cell
    }
    
//        метод для создания свайпа влево и кнопки удалить
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        Api.sharedApi.removePlaceFromDB(place_id: Api.sharedApi.favPlacesData[indexPath.row].place_id)
        // удалять руками из списка не нужно - мы подписаны на нотификацию при изменении базы данных
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
//                destinationVC.place = classPlace[indexPath.row]
                destinationVC.index = indexPath.row
                destinationVC.from = "fromFavorits"
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Api.sharedApi.clearFavoritsDB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        notificationToken?.stop()
    }
    
}

