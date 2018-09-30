//
//  AppDelegate.swift
//  Revolut
//
//  Created by Andrey Yashnev on 29/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   
        let endpointsProvider = EndpointsProvider()
        let factory = RatesListLoaderFactory(endpointProvider: endpointsProvider)
        let ratesService = RatesListService(factory: factory)
        let rateListPresenter = RatesListPresenter(rateListService: ratesService, baseCurrency: "EUR")
        
        window = UIWindow()
        window?.rootViewController = RatesListViewController(presenter: rateListPresenter)
        window?.makeKeyAndVisible()
        
        return true
    }

   


}

