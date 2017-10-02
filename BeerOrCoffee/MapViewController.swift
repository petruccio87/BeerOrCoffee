//
//  MapViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//


import UIKit
import RealmSwift
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate {
    
//    let api : Api = Api()
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
//    var classPlace : [Place] = []
    var mapView: GMSMapView!
    
    struct markerData{
        let from: String
        let index: Int
    }
    var from = "fromDetails"    // дефолтные значения для перехода по нажатию на маркер
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        view = mapView
        
        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
        
//__________________ обновление и установка маркеров заведений на карте _____________________
        func updateMarkers() {
            mapView.clear()
            
            Api.sharedApi.getPlacesDataFromDB()
            Api.sharedApi.getFavPlacesDataFromDB()
            for (index, place) in Api.sharedApi.placesData.enumerated() {
                let marker = GMSMarker()
                let latLng = place.latLng.components(separatedBy: ",")
                marker.position = CLLocationCoordinate2D(latitude: Double(latLng[0])!, longitude: Double(latLng[1])!)
                marker.title = place.place_name
                marker.snippet = place.address
                marker.map = mapView
                let tmpData = markerData(from: "fromDetails", index: index)
                marker.userData = tmpData
//                print("added marker \(marker) -- \(latLng[0]) -- \(latLng[1])")
            }
            for (index, place) in Api.sharedApi.favPlacesData.enumerated() {
                let marker = GMSMarker()
                let latLng = place.latLng.components(separatedBy: ",")
                marker.position = CLLocationCoordinate2D(latitude: Double(latLng[0])!, longitude: Double(latLng[1])!)
                marker.title = place.place_name
                marker.snippet = place.address
                marker.map = mapView
                let tmpData = markerData(from: "fromFavorits", index: index)
                marker.userData = tmpData
//                print("added marker \(marker.title ?? "title") -- \(Thread.current)")
            }
//            self.classPlace = self.api.loadClassPlacesListDB()
//            for place in self.classPlace {
//                let marker = GMSMarker()
//                let latLng = place.latLng.components(separatedBy: ",")
//                marker.position = CLLocationCoordinate2D(latitude: Double(latLng[0])!, longitude: Double(latLng[1])!)
//                marker.title = place.name
//                marker.snippet = place.address
//                marker.map = mapView
//                print("added marker \(marker) -- \(latLng[0]) -- \(latLng[1])")

//----------- свои иконки ----------
//                let iconName = place.icon.components(separatedBy: "/")
//                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                let iconURL = documentsURL.appendingPathComponent(iconName.last!)
//                marker.icon = UIImage(named: iconURL.path)
//            }
        }
        
        updateMarkers()     // при начальной загрузке, берет данные из старого поиска в базе
        notificationToken = realm.addNotificationBlock {notification, realm in
            updateMarkers() // после нового поиска в базе меняются данные и вызывается обновление маркеров
        }
//___________________________________________________________________________________________
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Marker Taped \((marker.userData as! markerData).index)")
        from = (marker.userData as! markerData).from
        index = (marker.userData as! markerData).index
        goToDetails()
        
    }
    
    func goToDetails() {
        performSegue(withIdentifier: "goToDetails", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.index = self.index
            destinationVC.from = self.from
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
            print("iOS version is to Low for LocalNotifications")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    deinit {
        notificationToken?.stop()
         print("map View deinit")
    }
    
}
