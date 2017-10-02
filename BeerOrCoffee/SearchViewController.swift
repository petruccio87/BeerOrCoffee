//
//  SearchViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 18.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import SwiftyJSON
import UserNotifications


class SearchViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var label: UILabel!
    

    
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        label.text = "Bar"
        
        // загрузка и установка новых фоновых картинок
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
        Api.sharedApi.downloadNewBG(height: String(describing: self.view.bounds.height), width: String(describing: self.view.bounds.width))
        
       // для today widget
        let defaults = UserDefaults(suiteName: "group.petruccio.BeerOrCoffee")
        if let _:String = defaults?.object(forKey: "name") as? String
        {
            defaults?.set("none", forKey: "name")           // если еще ничего не записано в defaults для todaywidget, то запишем none чтобы обработать этот момент в виджете
            defaults?.set("none", forKey: "raiting")
        }
        defaults?.synchronize()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in
                if let err = error {
                    print(err)
                }
                if didAllow {
                    print("get permishen succes")
                }else {
                    print("dont get permishen")
                }
            })
        } else {
            // Fallback on earlier versions
        }
        
        determineMyCurrentLocation()
        
        // загружает из firebase обязательные любимые заведения
        Database.database().reference().child("favorits").observe(.value, with: { snapshot in
            if let value = snapshot.value {
//                print(value)
                let json = JSON(value)
                for (key, subjson) in json {
                    if subjson.stringValue != "" {       // первый элемент всегда null
                        print("subjson \(key) + \(subjson.stringValue)")
                    Api.sharedApi.loadDefaultVafInfo(place_id: subjson.stringValue)
                    }                
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onChangeSelection(_ sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            label.text = "Bar"
            searchType = "Bar"
        case 1:
            label.text = "Cafe"
            searchType = "Cafe"
        default:
            label.text = "Bar"
            searchType = "Bar"
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search" {
            let destinationVC = segue.destination as! TableViewController
            destinationVC.searchType = searchType
            Api.sharedApi.clearResultsDB()
            Api.sharedApi.clearPhotosDB()
        }
        if segue.identifier == "details" {  // переход к деталям заведения из local notification
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.index = 0
            destinationVC.from = "fromDetails"
        }
    }
    
//_____________________ Start Location __________________________________
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        lat = userLocation.coordinate.latitude
        lng = userLocation.coordinate.longitude
//        print("My Lat = \(userLocation.coordinate.latitude)")
//        print("My Lng = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location Error: \(error)")
    }
//_____________________ End Location __________________________________
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true;
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
            print("iOS version is to Low for LocalNotifications")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = false;
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
