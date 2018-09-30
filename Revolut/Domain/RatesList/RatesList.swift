//
//  RatesList.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

struct RatesList: Codable {
    let base: String
    let date: String
    let rates: [String : Double]
}
