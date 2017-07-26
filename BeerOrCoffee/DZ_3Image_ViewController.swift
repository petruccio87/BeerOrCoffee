//
//  DZ_3Image_ViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 26.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit

class DZ_3Image_ViewController: UIViewController {

    let urls : [String] = ["http://www.avtorinok.ru/photo/BMW_X5_M_pic_137239.jpg",
                           "https://imagecdn3.luxnet.ua/tv24/resources/photos/news/640x480_DIR/201707/845508.jpg",
                           "http://www.wlsa.com.au/wp-content/uploads/2017/03/WLSA-kayaking2.jpg",
                           "https://smart-lab.ru/uploads/images/00/18/53/2015/07/21/e61bf2.jpg"]
    let api : Api = Api()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func printTest(_ sender: Any) {
        print("Print Test =)")
    }
    
    @IBAction func startLoad(_ sender: Any) {
        concurrentQueue.async(qos: .userInitiated) {
            print("Start cycle - \(Thread.current)")
            for url in self.urls {
                print("Load image - \(Thread.current)")
                let image = self.api.myLoadJPG(url: url)
                DispatchQueue.main.async {
                    print("Show image - \(Thread.current)")
                    self.imageView.image = image
                }
                print("Delay - \(Thread.current)")
                sleep(3)        // да, просто. но работает
            }
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

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
