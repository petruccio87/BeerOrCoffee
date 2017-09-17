//
//  AppDelegate.swift
//  BeerOrCoffee
//
//  Created by OSX on 13.07.17.
//  Copyright © 2017 OSX. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(apikey)
        FirebaseApp.configure()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Update placesData from background \(Date())")
        if lastUpdate != nil && abs(lastUpdate!.timeIntervalSinceNow) < 30 {
            print("Update cancel (last update less then 30 sec)")
            completionHandler(.noData)
            return
        }
//        func complite() {
//            
//        }
        
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(29), leeway: .seconds(1))
        timer?.setEventHandler {
            print("Error (to long data load in background)")
            completionHandler(.failed)
            return
        }
        timer?.resume()
        
        Api.sharedApi.clearResultsDB()
        Api.sharedApi.clearPhotosDB()
        print(Api.sharedApi.findPlaces(type: searchType, lat: lat, lng: lng))
        
        print("Update placesData complite")
        lastUpdate = Date()
        timer = nil
        completionHandler(.newData)
        return
        
    }


}

let apikey = "AIzaSyBzfEMMl1BGXGoLngcVuEdu2HvOGTMVT48"
var lat : Double = 0
var lng : Double = 0    // текущие координаты устройства
var searchType = "Bar"
