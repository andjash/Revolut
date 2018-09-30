
//
//  Parser.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

class Parser<T> {
    func parse(from: Data) throws -> T {
        fatalError("Abstract class can't be used")
    }
}

class CodableJsonParser<T: Codable> : Parser<T>  {
    
    private let decoder = JSONDecoder()
    
    override func parse(from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
}
