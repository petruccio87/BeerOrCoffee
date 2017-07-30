//
//  SearchViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 18.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var label: UILabel!
    
    var searchType = "Bar"      // передается аргументом в функцию поиска
    
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "bg.png")
        let imageViewBG = UIImageView(frame: self.view.bounds)
        imageViewBG.image = backgroundImage
        imageViewBG.contentMode = .scaleAspectFill
        view.addSubview(imageViewBG)
        view.sendSubview(toBack: imageViewBG)
        
            label.text = "Bar"
        // Do any additional setup after loading the view.
        
determineMyCurrentLocation()
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
            destinationVC.lat = lat
            destinationVC.lng = lng
        }
    }
    
//_____________________ Start Location __________________________________
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
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
