//
//  Loader.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

class Loader<T> {
    
    let parser: Parser<T>
    let fetcher: DataFetcher
    
    init(fetcher: DataFetcher, parser: Parser<T>) {
        self.fetcher = fetcher
        self.parser = parser
    }
    
    func load() throws -> T {
        return try parser.parse(from: fetcher.fetch())
    }
}
