//
//  TodayViewController.swift
//  BeerOrCoffeeTodayExtension
//
//  Created by OSX on 01.10.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var raitingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Please, start BeerOrCoffe."       // если программа еще не запускалась и данных нет никаких
        raitingLabel.text = ""
        let defaults = UserDefaults(suiteName: "group.petruccio.BeerOrCoffee")
        if let nameString:String = defaults?.object(forKey: "name") as? String
        {
            if nameString != "none" {           // если прогрмма запускалась, но еще ничего не искала и не записывала
                nameLabel.text = nameString
            } else {
                nameLabel.text = "The search was not yet"
            }
            
        }
        if let raitingString:String = defaults?.object(forKey: "raiting") as? String
        {
            if raitingString != "none" {
                if raitingString != ""{
                    raitingLabel.text = "Raiting: " + raitingString
                } else {
                    raitingLabel.text = "Raiting: -"
                }
            } else {
                raitingLabel.text = ""
            }
            
        }
        // open main app
        
        
        // Do any additional setup after loading the view from its nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let defaults = UserDefaults(suiteName: "group.petruccio.BeerOrCoffee")
        if let nameString:String = defaults?.object(forKey: "name") as? String
        {
            if nameString != "none" {           // если прогрмма запускалась, но еще ничего не искала и не записывала
                nameLabel.text = nameString
            } else {
                nameLabel.text = "The search was not yet"
            }
            
        }
        if let raitingString:String = defaults?.object(forKey: "raiting") as? String
        {
            if raitingString != "none" {
                if raitingString != ""{
                    raitingLabel.text = "Raiting: " + raitingString
                } else {
                    raitingLabel.text = "Raiting: -"
                }
            } else {
                raitingLabel.text = ""
            }
            
        }
        
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func touch(_ sender: Any) {
        openApp()
    }
    func openApp(){
        let myAppUrl = URL(string: "main-screen:")!
        extensionContext?.open(myAppUrl, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
    }
}
