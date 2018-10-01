//
//  RateListPresenterTests.swift
//  RevolutTests
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import XCTest
@testable import Revolut

class RateListPresenterTests: XCTestCase {
    
    
    class RatesListServiceMock: RatesListService {
        
        class StubError: Error {}
        
        var getRatesCalled = false
        var throwsError = false
        
        override func getRates(withBase base: String) throws -> RatesList {
            self.getRatesCalled = true
            if throwsError {
                throw StubError()
            }
            return RatesList(base: "EUR", date: "", rates: ["RUB" : Decimal(80),
                                                            "USD" : Decimal(1.2)])
        }
    }
    
    class RatesListPresenterDelegateMock: RatesListPresenterDelegate {
        
        var displayDataCalled = false
        var displayErrorCalled = false
        var focusCalled = false
        var entries: [RatesListPresenter.DataEntry] = []
        
        func display(data: [RatesListPresenter.DataEntry]) {
            entries = data
            displayDataCalled = true
        }
        
        func focusEntry(atIndex: Int, allData: [RatesListPresenter.DataEntry]) {
            entries = allData
            focusCalled = true
        }
        
        func display(error: String) {
            displayErrorCalled = true
        }
    }
    
    class RateListLoaderFactoryStub: RatesListLoaderFactory {}
    class EndpointsProviderStub: EndpointsProvider {}

    func testShouldStartLoadAfterViewIsReady() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        
        presenter.viewIsReady()
        
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        XCTAssert(ratesListServiceMock.getRatesCalled)
    }
    
    func testShouldDisplayDataAfterFirstLoad() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        XCTAssert(delegate.displayDataCalled)
    }
    
    func testShouldFocusAfterEditStart() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        presenter.didStartEditing(forEntry: delegate.entries[0], atIndex: 0)
        
        XCTAssert(delegate.focusCalled)
    }
    
    func testShouldDisplayNewDataAfterEdit() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        delegate.displayDataCalled = false
        presenter.didStartEditing(forEntry: delegate.entries[0], atIndex: 0)
        presenter.didEditValue(forEntry: delegate.entries[0], newValue: "1")
        
        XCTAssert(delegate.displayDataCalled)
    }
    
    func testShouldChangeDataAfterEdit() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.2))
        let dataBeforeEdit = delegate.entries[1].value
        presenter.didStartEditing(forEntry: delegate.entries[0], atIndex: 0)
        presenter.didEditValue(forEntry: delegate.entries[0], newValue: "1")
        let dataAfterEdit = delegate.entries[1].value
        
        XCTAssert(dataBeforeEdit != dataAfterEdit)
    }
    
    func testShouldGetRatesAfterPeriod() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.updatePeriod = 0.2
        
        presenter.viewIsReady()
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        ratesListServiceMock.getRatesCalled = false
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.3))
        
        XCTAssert(ratesListServiceMock.getRatesCalled)
    }
    
    func testShouldDisplayDataAfterPeriod() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.delegate = delegate
        presenter.updatePeriod = 0.2
        
        presenter.viewIsReady()
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        ratesListServiceMock.getRatesCalled = false
        delegate.displayDataCalled = false
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.3))
        
        XCTAssert(delegate.displayDataCalled)
    }
    
    func testShouldSaveOrderAfterAutoUpdate() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
       
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.delegate = delegate
        presenter.updatePeriod = 0.2
        
        presenter.viewIsReady()
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        presenter.didStartEditing(forEntry: delegate.entries[1], atIndex: 1)
        
        let firstAfterEdit = delegate.entries[0].currencyName
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.3))
        let firstAfterAutoupdate = delegate.entries[0].currencyName
        
        XCTAssert(firstAfterAutoupdate == firstAfterEdit)
    }
    
    
    func testShouldDisplayErrorIfServiceThrows() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        ratesListServiceMock.throwsError = true
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(delegate.displayErrorCalled)
    }

}
