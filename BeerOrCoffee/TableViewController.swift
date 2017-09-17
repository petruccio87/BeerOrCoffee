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
    var lat: Double = 0
    var lng: Double = 0
    var classPlace : [Place] = []
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
//        let backgroundImage = UIImage(named: "bg.png")            // для tableViewController
//        let imageView = UIImageView(image: backgroundImage)
//        imageView.contentMode = .scaleAspectFill
//        self.view.backgroundView = imageView
        let backgroundImage = UIImage(named: "bg.png")
        let imageViewBG = UIImageView(frame: self.view.bounds)
        imageViewBG.image = backgroundImage
        imageViewBG.contentMode = .scaleAspectFill
        view.addSubview(imageViewBG)
        view.sendSubview(toBack: imageViewBG)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        headerView.backgroundColor = UIColor.yellow
        let headerTitleView = UILabel(frame: CGRect(x: headerView.center.x - 50, y: 20, width: 100, height: 20))
        headerTitleView.text = "Results"
        let headerBackView = UIButton(frame: CGRect(x: 5, y: 20, width: 20, height: 20))
        headerBackView.tintColor = UIColor.blue
        headerBackView.setTitle("<", for: .normal)
        headerBackView.addTarget(self, action: #selector(TableViewController.goBack), for: .touchDown)
        headerView.addSubview(headerBackView)
        headerView.addSubview(headerTitleView)
        self.view.addSubview(headerView)
        
        
        
        myActivityIndicator.center = self.view.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
        
 // ищем каждый раз
        
//        print("1. start find places \(Thread.current)")
        Api.sharedApi.clearResultsDB()
        Api.sharedApi.clearPhotosDB()
        print(Api.sharedApi.findPlaces(type: self.searchType, lat: self.lat, lng: self.lng))
        
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
//        
//------------------- Работает через реалм нотификацию -------------------
// ищем каждый раз
//        print(api.findPlaces(type: searchType, lat: lat, lng: lng))
 // загружаем все данные из базы
//  прекрасно работает, но нам надо сделать свою нотификацию вместо реалмовской
        notificationToken = realm.addNotificationBlock {notification, realm in
//            self.classPlace = self.api.loadClassPlacesListDB()
            Api.sharedApi.getPlacesDataFromDB()
            self.tableView.reloadData()
        }
//-----------------------------------------------------------------------
    
    }
    
    func refreshTableView() {
//        self.classPlace = self.api.loadClassPlacesListDB()

        DispatchQueue.main.async {
            print("refresh   \(Thread.current)")
//            Api.sharedApi.getPlacesDataFromDB()
            self.tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return classPlace.count
        print("Api.sharedApi.placesData.count:  \(Api.sharedApi.placesData.count)")
        return Api.sharedApi.placesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = classPlace[indexPath.row].name
        cell.textLabel?.text = Api.sharedApi.placesData[indexPath.row].place_name
//        cell.textLabel?.text = ManagerData.sharedManager.weatherData[indexPath.row].city_name
        if Api.sharedApi.placesData[indexPath.row].raiting == "" {
            cell.detailTextLabel?.text = "Raiting: -"
        } else {
//            cell.detailTextLabel?.text = "Raiting: " + classPlace[indexPath.row].rating
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
//                destinationVC.place = classPlace[indexPath.row]
                destinationVC.index = indexPath.row
                destinationVC.from = "fromDetails"
            }
            
        }
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        notificationToken?.stop()       //  включить когда используется реальмовская нотификация
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "writePlaceToDB"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        //        Api.sharedApi.clearResultsDB()
        //        self.navigationController?.isNavigationBarHidden = true;
        self.tabBarController?.tabBar.isHidden = false
    }
}

