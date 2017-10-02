//
//  DetailsViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//


import UIKit
import RealmSwift
import GoogleMaps
import Agrume

class DetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageViewBG: UIImageView!



    
    var notificationToken: NotificationToken? = nil
    let realm = try! Realm()
    
//    var place = Place()
    var index: Int =  -1
    var from = "fromDetails"  // fromDetails or fromFaforits
    var markerLatLng : [String] = []
    var place_id : String = ""
    var markerTitle : String = ""
    var markerSnippet : String = ""
    var photos : [UIImage] = []
//    let api : Api = Api()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 800)
        Api.sharedApi.getPlacesDataFromDB()
        
        
        let newName = "newbg.jpeg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent(newName).path
        //        let filePath = url.appendingPathComponent("nameOfFileHere").path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("NewBG AVAILABLE")
            let backgroundImage = UIImage(named: filePath)
            imageViewBG.image = backgroundImage
            imageViewBG.contentMode = .scaleAspectFill
//            view.addSubview(imageViewBG)
//            view.sendSubview(toBack: imageViewBG)
        } else {
            print("NewBG NOT AVAILABLE")
            let backgroundImage = UIImage(named: "bg.png")
//            let imageViewBG = UIImageView(frame: self.view.bounds)
            imageViewBG.image = backgroundImage
            imageViewBG.contentMode = .scaleAspectFill
//            view.addSubview(imageViewBG)
//            view.sendSubview(toBack: imageViewBG)
        }
        
//        self.navigationItem.hidesBackButton = true
//        let newBackButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailsViewController.goBack))
//        self.navigationItem.leftBarButtonItem = newBackButton
        
//        let backgroundImage = UIImage(named: "bg.png")
//        let imageViewBG = UIImageView(frame: self.view.bounds)
//        imageViewBG.image = backgroundImage
//        imageViewBG.contentMode = .scaleAspectFill
//        self.view.addSubview(imageViewBG)
//        self.view.sendSubview(toBack: imageViewBG)
        
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
//        headerView.backgroundColor = UIColor.yellow
//        let headerTitleView = UILabel(frame: CGRect(x: headerView.center.x - 50, y: 20, width: 100, height: 20))
//        headerTitleView.text = "Details"
//        let headerBackView = UIButton(frame: CGRect(x: 5, y: 20, width: 20, height: 20))
//        headerBackView.tintColor = UIColor.blue
//        headerBackView.setTitle("<", for: .normal)
//        headerBackView.addTarget(self, action: #selector(TableViewController.goBack), for: .touchDown)
//        headerView.addSubview(headerBackView)
//        headerView.addSubview(headerTitleView)
//        self.view.addSubview(headerView)
        
        
        
        
        
        let nameLabel : UILabel = self.view.viewWithTag(1) as! UILabel
        let ratingLabel : UILabel = self.view.viewWithTag(2) as! UILabel
        let priceLevelLabel : UILabel = self.view.viewWithTag(3) as! UILabel
        let latLngLabel : UILabel = self.view.viewWithTag(4) as! UILabel
        let addressLabel : UILabel = self.view.viewWithTag(5) as! UILabel
        let favButton : UIButton = self.view.viewWithTag(6) as! UIButton
        // Do any additional setup after loading the view.
        
        notificationToken = realm.addNotificationBlock {[weak self] notification, realm in
            Api.sharedApi.getPhotoDataFromDB(place_id: (self?.place_id)!)
            Api.sharedApi.getPlacesDataFromDB()
            self?.collectionView.reloadData()
        }
        
        
        if from == "fromDetails"{
            nameLabel.text = Api.sharedApi.placesData[index].place_name
            ratingLabel.text = Api.sharedApi.placesData[index].raiting
            priceLevelLabel.text = Api.sharedApi.placesData[index].price_level
            latLngLabel.text = Api.sharedApi.placesData[index].latLng
            addressLabel.text = Api.sharedApi.placesData[index].address
//            addressLabel.text = "Россия, г.Москва, ул.вторая Тверская-ямская, дом 13, корпус 18" 
            markerLatLng = Api.sharedApi.placesData[index].latLng.components(separatedBy: ",")
            markerTitle = Api.sharedApi.placesData[index].place_name
            markerSnippet = Api.sharedApi.placesData[index].address
            place_id = Api.sharedApi.placesData[index].place_id
        } else if from == "fromFavorits" {
            nameLabel.text = Api.sharedApi.favPlacesData[index].place_name
            ratingLabel.text = Api.sharedApi.favPlacesData[index].raiting
            priceLevelLabel.text = Api.sharedApi.favPlacesData[index].price_level
            latLngLabel.text = Api.sharedApi.favPlacesData[index].latLng
            addressLabel.text = Api.sharedApi.favPlacesData[index].address
            markerLatLng = Api.sharedApi.favPlacesData[index].latLng.components(separatedBy: ",")
            markerTitle = Api.sharedApi.favPlacesData[index].place_name
            markerSnippet = Api.sharedApi.favPlacesData[index].address
            place_id = Api.sharedApi.favPlacesData[index].place_id
        }
        
//        Api.sharedApi.findPlaceInfo(place_id: place_id)
        concurrentQueue.async {
//            if Api.sharedApi.photoData.count == 0 {
////                if self.from == "fromFavorits" {
////                    Api.sharedApi.findPlaceInfo(place_id: self.place_id, favorit: true)
////                } else {
////                    Api.sharedApi.findPlaceInfo(place_id: self.place_id, favorit: false)
////                }
//                Api.sharedApi.getPhotoDataFromDB(place_id: self.place_id)
//                for index in Api.sharedApi.photoData {
//                    concurrentQueue.sync {[weak self] in
//                        let image = Api.sharedApi.loadPhoto(url: index.place_photo)
//                        self?.photos.append(image)
//                        DispatchQueue.main.async {
//                            self?.collectionView.reloadData()
//                        }
//                    }
//                }
//            } else {
                Api.sharedApi.getPhotoDataFromDB(place_id: self.place_id)
                for index in Api.sharedApi.photoData {
                    concurrentQueue.sync {[weak self] in
                        let image = Api.sharedApi.loadPhoto(url: index.place_photo)
                        self?.photos.append(image)
                        DispatchQueue.main.async {
                            self?.collectionView.reloadData()
                        }
                    }
//                }
            }
        }
        
        if Api.sharedApi.isFavorit(place_id: place_id) {
            //        if Api.sharedApi.placesData[index].favorit {
            let favImage = UIImage(named: "star_true.png")
            favButton.setImage(favImage, for: .normal)
        } else {
            let favImage = UIImage(named: "star_false.png")
            favButton.setImage(favImage, for: .normal)
        }
        mapView.camera = GMSCameraPosition.camera(withLatitude: Double(markerLatLng[0])!, longitude: Double(markerLatLng[1])!, zoom: 15.0)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Double(markerLatLng[0])!, longitude: Double(markerLatLng[1])!)
        marker.title = markerTitle
        marker.snippet = markerSnippet
        marker.map = mapView
        mapView.selectedMarker = marker // открывает описание маркера
        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
//        let iconName = place.icon.components(separatedBy: "/")
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let iconURL = documentsURL.appendingPathComponent(iconName.last!)
//        marker.icon = UIImage(named: iconURL.path)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// ------- collection view -----------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        Api.sharedApi.getPhotoDataFromDB(place_id: self.place_id)
//        print("количествое картинок - ", Api.sharedApi.photoData.count)
//        return Api.sharedApi.photoData.count
        
        print("количествое картинок - ", photos.count)
        return photos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView: UIImageView = cell.viewWithTag(7) as! UIImageView
//        let image = Api.sharedApi.loadPhoto(url: Api.sharedApi.photoData[indexPath.row].place_photo)
        let image = photos[indexPath.row]
        imageView.image = image
//        imageView.image = UIImage(named: ManagerData.sharedManager.weatherData[index].tempList[indexPath.row].icon)
//        imageView.image = UIImage(named: "star_false")

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let agrume = Agrume(images: photos, startIndex: indexPath.row, backgroundBlurStyle: .light)
        agrume.didScroll = { [unowned self] index in
            self.collectionView?.scrollToItem(at: IndexPath(row: index, section: 0), at: [], animated: false)
        }
        agrume.showFrom(self)
    }
// -----------------------------------------

// кнопка favorit- добавляет в базу любимых, если заведения там нет, и удаляет из базы любимых, если оно там есть.
    @IBAction func favorit(_ sender: UIButton) {
        var alertmessg = ""
        Api.sharedApi.makeFavorit(place_id: place_id)
        if from == "fromDetails" {
            viewDidLoad()
        } else if from == "fromFavorits" {
            let favButton : UIButton = self.view.viewWithTag(6) as! UIButton
            if Api.sharedApi.isFavorit(place_id: place_id) {
                //        if Api.sharedApi.placesData[index].favorit {
                let favImage = UIImage(named: "star_true.png")
                favButton.setImage(favImage, for: .normal)
                alertmessg = "Добавлено в любимые"
            } else {
                let favImage = UIImage(named: "star_false.png")
                favButton.setImage(favImage, for: .normal)
                alertmessg = "Удалено из любимых"
            }
            let alert = UIAlertController(title: "Alert", message: alertmessg, preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(actionOK)
            self.present(alert, animated: true, completion: nil)
        }
//        let realm = try! Realm()
//        
//        if realm.objects(PlacesData.self).filter("place_id BEGINSWITH %@", Api.sharedApi.placesData[index].place_id).count > 0 {
//            let data = realm.objects(PlacesData.self).filter("place_id BEGINSWITH %@", Api.sharedApi.placesData[index].place_id)
//            if data[0].favorit {                   // если есть в favorits то удаляем из базы
////                Api.sharedApi.removePlaceFromDB(place_id: Api.sharedApi.placesData[index].place_id)
//                Api.sharedApi.placesData[index].favorit = false           // для изменения картинки звезды
//                viewDidLoad()
//            }
//        } else {
//            let newdata = FavoritsData()        // если нет в favorits то добавляем в базу
//            newdata.place_name = Api.sharedApi.placesData[index].place_name
//            newdata.place_id = Api.sharedApi.placesData[index].place_id
//            newdata.place_icon = Api.sharedApi.placesData[index].place_icon
//            newdata.raiting = Api.sharedApi.placesData[index].raiting
//            newdata.price_level = Api.sharedApi.placesData[index].price_level
//            newdata.latLng = Api.sharedApi.placesData[index].latLng
//            newdata.address = Api.sharedApi.placesData[index].address
//            newdata.favorit = true
//            try! realm.write {
//                realm.add(newdata, update: true)
//            }
//            Api.sharedApi.placesData[index].favorit = true           // для изменения картинки звезды
//            viewDidLoad()
//    }
        
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
            print("iOS version is to Low for LocalNotifications")
        }
    }
    
    
    deinit {
        notificationToken?.stop()
        print("details View deinit")
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
