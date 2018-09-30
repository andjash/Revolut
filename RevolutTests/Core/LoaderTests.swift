//
//  LoaderTests.swift
//  RevolutTests
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import XCTest
@testable import Revolut

class LoaderTests: XCTestCase {
    
    
    struct NoDataError: Error {}
    
    class FetcherMock: DataFetcher {
        
        var stubData: Data?
        var errorToThrow: Error?
        var fetchCalled = false
        
        func fetch() throws -> Data {
            fetchCalled = true
            if let err = errorToThrow {
                throw err
            }
            if let data = stubData {
                return data
            }
            throw NoDataError()
        }
    }
    
    class ParserMock<T>: Parser<T> {
       
        var objectToReturn: T?
        var inputData: Data?
        var errorToThrow: Error?
        var parseCalled = false
        
        override func parse(from data: Data) throws -> T {
            inputData = data
            parseCalled = true
            if let err = errorToThrow {
                throw err
            }
            if let obj = objectToReturn {
                return obj
            }
            throw NoDataError()
        }
    }

    func testLoaderWillUseFetcher() {
        let parserMock = ParserMock<String>()
        parserMock.objectToReturn = "Str"
        let fetcherMock = FetcherMock()
        fetcherMock.stubData = Data()
        let loader = Loader(fetcher: fetcherMock, parser: parserMock)
       
        let _ = try! loader.load()
        
        XCTAssert(fetcherMock.fetchCalled)
    }
    
    func testLoaderWillUseParser() {
        let parserMock = ParserMock<String>()
        parserMock.objectToReturn = "Str"
        let fetcherMock = FetcherMock()
        fetcherMock.stubData = Data()
        let loader = Loader(fetcher: fetcherMock, parser: parserMock)
        
        let _ = try! loader.load()
        
        XCTAssert(parserMock.parseCalled)
    }
    
    func testParserWillReceiveDataFromFetcher() {
        let parserMock = ParserMock<String>()
        parserMock.objectToReturn = "Str"
        let fetcherMock = FetcherMock()
        fetcherMock.stubData = "Str".data(using: .utf8)!
        let loader = Loader(fetcher: fetcherMock, parser: parserMock)
        
        let _ = try! loader.load()
        
        XCTAssert(parserMock.inputData! == fetcherMock.stubData)
    }
    
    func testLoaderWillReturnObjectFromParser() {
        let parserMock = ParserMock<String>()
        parserMock.objectToReturn = "Str"
        let fetcherMock = FetcherMock()
        fetcherMock.stubData = "Str".data(using: .utf8)!
        let loader = Loader(fetcher: fetcherMock, parser: parserMock)
        
        let result = try! loader.load()
        
        XCTAssert(result == parserMock.objectToReturn!)
    }
    
    func testLoaderWillThrowIfFetcherThrows() {
        let parserMock = ParserMock<String>()
        parserMock.objectToReturn = "Str"
        let fetcherMock = FetcherMock()
        fetcherMock.errorToThrow = NoDataError()
        fetcherMock.stubData = "Str".data(using: .utf8)!
        let loader = Loader(fetcher: fetcherMock, parser: parserMock)
        
        var loaderError: Error?
        
        do {
            let _ = try loader.load()
        } catch {
            loaderError = error
        }
        
        XCTAssert(loaderError != nil)
    }
    
    func testLoaderWillThrowIfParserThrows() {
        let parserMock = ParserMock<String>()
        parserMock.objectToReturn = "Str"
        parserMock.errorToThrow = NoDataError()
        let fetcherMock = FetcherMock()
        fetcherMock.stubData = "Str".data(using: .utf8)!
        let loader = Loader(fetcher: fetcherMock, parser: parserMock)
        
        var loaderError: Error?
        
        do {
            let _ = try loader.load()
        } catch {
            loaderError = error
        }
        
        XCTAssert(loaderError != nil)
    }
    

}
