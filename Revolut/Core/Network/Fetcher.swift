//
//  Fetcher.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

protocol DataFetcher {
    func fetch() throws -> Data
}

class PrimitiveNetworkDataFetcher: DataFetcher {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func fetch() throws -> Data {
        return try Data(contentsOf: url)
    }
}
