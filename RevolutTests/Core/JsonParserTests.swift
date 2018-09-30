//
//  JsonParserTests.swift
//  RevolutTests
//
//  Created by Andrey Yashnev on 29/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import XCTest
@testable import Revolut

class JsonParserTests: XCTestCase {

    func testItWillParseDictionary() {
        let parser: Parser<Dictionary<String,Int>> = CodableJsonParser<Dictionary<String,Int>>()
        let data = "{  \"a\": 42 }".data(using: .utf8)!
        
        let result = try! parser.parse(from: data)
        
        XCTAssert(result["a"] == 42)
    }
    
    func testItWillParseRatesList() {
        let parser: Parser<RatesList> = CodableJsonParser<RatesList>()
        let data = """
                     {
                        \"base\": \"EUR\",
                        \"date\": \"2018-09-06\",
                        \"rates\": {
                            \"AUD\": 1.6235,
                        }
                     }
                    """.data(using: .utf8)!
        
        let result = try! parser.parse(from: data)
        
        XCTAssert(result.base == "EUR")
        XCTAssert(result.date == "2018-09-06")
        XCTAssert(result.rates.count == 1)
        XCTAssert(result.rates["AUD"] == 1.6235)
    }
    
    func testItWillNotParseInvalidJson() {
        let parser: Parser<Dictionary<String,Int>> = CodableJsonParser<Dictionary<String,Int>>()
        let data = "{  \"a\"= 42 }".data(using: .utf8)!
        
        var parseError: Error?
        do {
            let _ = try parser.parse(from: data)
        } catch {
            parseError = error
        }
        
        XCTAssert(parseError != nil)
    }
    
    func testItWillFailToParseEmptyObject() {
        let parser: Parser<RatesList> = CodableJsonParser<RatesList>()
        let data = "{}".data(using: .utf8)!
        
        var parseError: Error?
        do {
            let _ = try parser.parse(from: data)
        } catch {
            parseError = error
        }
        
        XCTAssert(parseError != nil)
    }

}
