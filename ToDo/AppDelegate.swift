//
//  AppDelegate.swift
//  ToDo
//
//  Created by Vicente Orellana on 9/3/18.
//  Copyright © 2018 Vicente Orellana. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let defaults = UserDefaults.standard
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let defaultValues = ["ToDo" : "", "ToRemember" : ""]
        defaults.register(defaults: defaultValues)
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
        let currentTime = Date()
        let sevenAM = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: currentTime)!
        var thingsToRemember: [thingToRemember] = [] {
            didSet {
                let rememberData = thingsToRemember.map { $0.encode() }
                defaults.set(rememberData, forKey: "ToRemember")
            }
        }
        
        if let toRememberObject = defaults.object(forKey: "ToRemember") as? [Data] {
            thingsToRemember = toRememberObject.compactMap { return thingToRemember(data: $0) }
        }
        
        thingsToRemember.enumerated().reversed().forEach {
            if let diff = Calendar.current.dateComponents([.hour], from: $1.date, to: Date()).hour, diff >= 7 && currentTime <= sevenAM {
                var sendData = [String: String]()
                sendData["newEntry"] = $1.thing
                thingsToRemember.remove(at: $0)
                NotificationCenter.default.post(name: toRememberNotification, object: nil, userInfo: sendData)
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

