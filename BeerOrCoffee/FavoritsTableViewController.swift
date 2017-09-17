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



class FavoritsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
//    let api : Api = Api()
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    
//    var classPlace : [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        
        let backgroundImage = UIImage(named: "bg.png")
        let imageViewBG = UIImageView(frame: self.view.bounds)
        imageViewBG.image = backgroundImage
        imageViewBG.contentMode = .scaleAspectFill
        view.addSubview(imageViewBG)
        view.sendSubview(toBack: imageViewBG)
//        let backgroundImage = UIImage(named: "bg.png")
//        let imageView = UIImageView(image: backgroundImage)
//        imageView.contentMode = .scaleAspectFill
//        self.tableView.backgroundView = imageView
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
//        headerView.backgroundColor = UIColor.yellow
//        let headerTitleView = UILabel(frame: CGRect(x: headerView.center.x - 50, y: 20, width: 100, height: 20))
//        headerTitleView.text = "Favorits"
//        let headerBackView = UIButton(frame: CGRect(x: 5, y: 20, width: 20, height: 20))
//        headerBackView.tintColor = UIColor.blue
//        headerBackView.setTitle("<", for: .normal)
//        headerBackView.addTarget(self, action: #selector(TableViewController.goBack), for: .touchDown)
//        headerView.addSubview(headerBackView)
//        headerView.addSubview(headerTitleView)
        self.view.addSubview(headerView)
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        if segue.identifier == "new" {
            
            
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
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        notificationToken?.stop()
    }
    
}

