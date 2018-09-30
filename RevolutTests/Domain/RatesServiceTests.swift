//
//  RatesServiceTests.swift
//  RevolutTests
//
//  Created by Andrey Yashnev on 29/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import XCTest
@testable import Revolut

class RatesServiceTests: XCTestCase {
    
    class EndpointsProviderMock: EndpointsProvider {
        
        var latestRatesCalled = false
        
        override func latestRatesListEndpoint(baseCurrency: String) -> URL {
            latestRatesCalled = true
            return super.latestRatesListEndpoint(baseCurrency: baseCurrency)
        }
    }
    
    
    func testFactoryWillUseProperEndpoint() {
        let mock = EndpointsProviderMock()
        let factory = RatesListLoaderFactory(endpointProvider: mock)
        
        let _ = factory.loader(forBaseRate: "EUR")
        
        XCTAssert(mock.latestRatesCalled)
    }

    

}
