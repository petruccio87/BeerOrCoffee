//
//  ViewController.swift
//  BeerOrCoffee
//
//  Created by Petr Shibalov on 05.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit

import Alamofire
import RealmSwift
import SwiftyJSON



class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let api : Api = Api()
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil     // нотификация realm
    var searchType = "Bar"  // меняется через seque

    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.featured, tag: 2)
        tableView.delegate = self
        tableView.dataSource = self

      
        // установка новых фоновых картинок
        let newName = "newbg.jpeg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent(newName).path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("NewBG AVAILABLE")
            let backgroundImage = UIImage(named: filePath)
            let imageViewBG = UIImageView(frame: self.view.bounds)
            imageViewBG.image = backgroundImage
            imageViewBG.contentMode = .scaleAspectFill
            view.addSubview(imageViewBG)
            view.sendSubview(toBack: imageViewBG)
        } else {
            print("NewBG NOT AVAILABLE")
            let backgroundImage = UIImage(named: "bg.png")
            let imageViewBG = UIImageView(frame: self.view.bounds)
            imageViewBG.image = backgroundImage
            imageViewBG.contentMode = .scaleAspectFill
            view.addSubview(imageViewBG)
            view.sendSubview(toBack: imageViewBG)
        }
  
// как памятка - не нужно
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
//        headerView.backgroundColor = UIColor.yellow
//        let headerTitleView = UILabel(frame: CGRect(x: headerView.center.x - 50, y: 20, width: 100, height: 20))
//        headerTitleView.text = "Results"
//        let headerBackView = UIButton(frame: CGRect(x: 5, y: 20, width: 20, height: 20))
//        headerBackView.tintColor = UIColor.blue
//        headerBackView.setTitle("<", for: .normal)
//        headerBackView.addTarget(self, action: #selector(TableViewController.goBack), for: .touchDown)
//        headerView.addSubview(headerBackView)
//        headerView.addSubview(headerTitleView)
//        self.view.addSubview(headerView)
        
        
        
        myActivityIndicator.center = self.view.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
 // сам поиск заведений
        
//        print("1. start find places \(Thread.current)")
        
        if lat != 0 && lng != 0 {       // если нет координат, то и искать нечего
//            Api.sharedApi.clearResultsDB()
//            Api.sharedApi.clearPhotosDB()
            print(Api.sharedApi.findPlaces(type: self.searchType, lat: lat, lng: lng))
        } else {
            let alert = UIAlertController(title: "Alert", message: "No GPS data.", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(actionOK)
            self.present(alert, animated: true, completion: nil)
        }
        
 // как памятка - не нужно
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
//    
        //    func refreshTableView() {
        //        DispatchQueue.main.async {[weak self] in
        //            print("refresh   \(Thread.current)")
        ////            Api.sharedApi.getPlacesDataFromDB()
        //            self?.tableView.reloadData()
        //        }
        //    }

        
//------------------- Работает через реалм нотификацию -------------------
 // загружаем данные из базы, при ее изменении
//  прекрасно работает, но нам надо сделать свою нотификацию вместо реалмовской
        
        notificationToken = realm.addNotificationBlock {notification, realm in
            Api.sharedApi.getPlacesDataFromDB()
            self.tableView.reloadData()
        }
//-----------------------------------------------------------------------
    
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Api.sharedApi.placesData.count:  \(Api.sharedApi.placesData.count)")
        return Api.sharedApi.placesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Api.sharedApi.placesData[indexPath.row].place_name
        if Api.sharedApi.placesData[indexPath.row].raiting == "" {
            cell.detailTextLabel?.text = "Raiting: -"
        } else {
            cell.detailTextLabel?.text = "Raiting: " + Api.sharedApi.placesData[indexPath.row].raiting
        }
        cell.backgroundColor = .clear
        myActivityIndicator.stopAnimating()
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.index = indexPath.row
                destinationVC.from = "fromDetails"
            }
            
        }
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// как памятка - не нужно
//    func goBack() {
//        dismiss(animated: true, completion: nil)
//    }

    deinit {
        notificationToken?.stop()       //  включить когда используется реальмовская нотификация
        print("details View deinit")
        
// как памятка по нотификации - не нужно
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        //        Api.sharedApi.clearResultsDB()
        //        self.navigationController?.isNavigationBarHidden = true;

        if #available(iOS 10.0, *) {
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
            print("iOS version is to Low for LocalNotifications")
        }
    }
}

