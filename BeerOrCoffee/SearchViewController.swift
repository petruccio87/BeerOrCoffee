//
//  SearchViewController.swift
//  BeerOrCoffee
//
//  Created by OSX on 18.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var label: UILabel!
    
    var searchType = "Bar"      // передается аргументом в функцию поиска
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            label.text = "Bar"
        // Do any additional setup after loading the view.
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

}
