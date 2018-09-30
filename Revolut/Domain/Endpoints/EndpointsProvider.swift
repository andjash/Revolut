//
//  EndpointsProvider.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

class EndpointsProvider {
    
    private let baseUrlString = "https://revolut.duckdns.org/"
    
    func latestRatesListEndpoint(baseCurrency: String) -> URL {
        return URL(string: baseUrlString + "latest?base=\(baseCurrency)")!
    }
    
}
