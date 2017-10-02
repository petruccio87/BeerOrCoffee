//
//  DZ_3Image_ViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 26.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

//  Для проекта не нужен. Одна из домашек.


import UIKit

class DZ_3Image_ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    let urls : [String] = ["https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CmRaAAAAcAlNkhrzptTYlLsal-zUFgqah7jqeYfVn5eWBFOEN-5OTuwq2ZlC0_aerC_f7MGp0zFGUL-apaaXU6bMQ2fzMHPauo6xAzPHcZPKs5nNUUCVPAzIlFO1f3LICWkl86DVEhDAmJJWNiOllxClKSt-Ey0nGhTjjrds37yb6xsr8akFT6yYjTJ_DA&key=AIzaSyBzfEMMl1BGXGoLngcVuEdu2HvOGTMVT48",
                            "http://www.avtorinok.ru/photo/BMW_X5_M_pic_137239.jpg",
                           "https://imagecdn3.luxnet.ua/tv24/resources/photos/news/640x480_DIR/201707/845508.jpg",
                           "http://www.wlsa.com.au/wp-content/uploads/2017/03/WLSA-kayaking2.jpg",
                           "https://smart-lab.ru/uploads/images/00/18/53/2015/07/21/e61bf2.jpg"]
    var urlIndex = 0
    
    let api : Api = Api()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func printTest(_ sender: Any) {
        print("Print Test =)")
    }
    
//    @IBAction func startLoad(_ sender: Any) {
//        concurrentQueue.async(qos: .userInitiated) {
//            print("Start cycle - \(Thread.current)")
//            for url in self.urls {
//                print("Load image - \(Thread.current)")
//                let image = self.myLoadJPG(url: url)
//                DispatchQueue.main.sync {
//                    print("Show image - \(Thread.current)")
//                    self.imageView.image = image
//                }
//                print("Delay - \(Thread.current)")
//                sleep(3)        // да, просто. но работает
//            }
//        }
//    }
    
    @IBAction func startLoad(_ sender: Any) {
        self.load()
    }
    
    func load() {
        concurrentQueue.async(qos: .userInitiated) {
            if  self.urlIndex < self.urls.count {
                print("Load image - \(Thread.current)")
                let image = self.myLoadJPG(url: self.urls[self.urlIndex])
                DispatchQueue.main.sync {
                    print("Show image - \(Thread.current)")
                    self.imageView.image = image
                    self.urlIndex += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        self.load()
                    }
                }
                print("Delay - \(Thread.current)")
            } else {
                print("end loading urls")
                self.urlIndex = 0
            }
        }
    }
    func myLoadJPG(url: String) -> UIImage {
        var image = UIImage()
        var imageData: Data?
        let url1 = URL(string: url)
        concurrentQueue.sync() {
            print("1. start \(Thread.current)")
            do {
                imageData = try  Data(contentsOf: url1!)
                print("2. dataload \(imageData)")
            } catch{
                print("error")
            }
            if let value =  imageData{
                image = UIImage(data: value)!
                print("3. image \(image)")
            }
            
        }
        print("4. return \(image)")
        return image
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 1750)
 
        let backgroundImage = UIImage(named: "bg.png")
                let imageViewBG = UIImageView(frame: self.view.bounds)
                imageViewBG.image = backgroundImage
                imageViewBG.contentMode = .scaleAspectFill
                self.view.addSubview(imageViewBG)
                self.view.sendSubview(toBack: imageViewBG)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
