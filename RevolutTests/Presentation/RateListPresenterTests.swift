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
    
    class QueueServiceStub : QueueService {
        override func queueNetwork<T>(operation: @escaping () throws -> T,
                             completion: ((T) -> ())?,
                             onError: ((Error) -> ())?,
                             finally: (() -> ())? )  {
            var result: T!
            do {
                result = try operation()
                completion?(result)
            } catch {
                onError?(error)
            }
            finally?()
        }
    }
    
    class RateListLoaderFactoryStub: RatesListLoaderFactory {}
    class EndpointsProviderStub: EndpointsProvider {}

    func testShouldStartLoadAfterViewIsReady() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        
        presenter.viewIsReady()
        
        XCTAssert(ratesListServiceMock.getRatesCalled)
    }
    
    func testShouldDisplayDataAfterFirstLoad() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        
        XCTAssert(delegate.displayDataCalled)
    }
    
    func testShouldFocusAfterEditStart() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        presenter.didStartEditing(forEntry: delegate.entries[0], atIndex: 0)
        
        XCTAssert(delegate.focusCalled)
    }
    
    func testShouldDisplayNewDataAfterEdit() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        delegate.displayDataCalled = false
        presenter.didStartEditing(forEntry: delegate.entries[0], atIndex: 0)
        presenter.didEditValue(forEntry: delegate.entries[0], newValue: "1")
        
        XCTAssert(delegate.displayDataCalled)
    }
    
    func testShouldChangeDataAfterEdit() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        let dataBeforeEdit = delegate.entries[1].value
        presenter.didStartEditing(forEntry: delegate.entries[0], atIndex: 0)
        presenter.didEditValue(forEntry: delegate.entries[0], newValue: "2")
        let dataAfterEdit = delegate.entries[1].value
        
        XCTAssert(dataBeforeEdit != dataAfterEdit)
    }
    
    func testShouldGetRatesAfterPeriod() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.updatePeriod = 0.01
        
        presenter.viewIsReady()
        ratesListServiceMock.getRatesCalled = false
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.02))
        
        XCTAssert(ratesListServiceMock.getRatesCalled)
    }
    
    func testShouldDisplayDataAfterPeriod() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        presenter.updatePeriod = 0.01
        
        presenter.viewIsReady()
        ratesListServiceMock.getRatesCalled = false
        delegate.displayDataCalled = false
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.02))
        
        XCTAssert(delegate.displayDataCalled)
    }
    
    func testShouldSaveOrderAfterAutoUpdate() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
       
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        presenter.updatePeriod = 0.01
        
        presenter.viewIsReady()
        presenter.didStartEditing(forEntry: delegate.entries[1], atIndex: 1)
        
        let firstAfterEdit = delegate.entries[0].currencyName
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.02))
        let firstAfterAutoupdate = delegate.entries[0].currencyName
        
        XCTAssert(firstAfterAutoupdate == firstAfterEdit)
    }
    
    
    func testShouldDisplayErrorIfServiceThrows() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        ratesListServiceMock.throwsError = true
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        
        XCTAssert(delegate.displayErrorCalled)
    }
    
    func testShouldPresentBaseCurrency() {
        let ratesListServiceMock = RatesListServiceMock(factory: RateListLoaderFactoryStub(endpointProvider: EndpointsProviderStub()))
        let delegate = RatesListPresenterDelegateMock()
        let presenter = RatesListPresenter(rateListService: ratesListServiceMock, queueService: QueueServiceStub(), baseCurrency: "EUR")
        presenter.delegate = delegate
        
        presenter.viewIsReady()
        
        let eurEntry = delegate.entries.first(where: { $0.currencyName == "EUR" && $0.value == "1" })
        XCTAssert(eurEntry != nil)
    }

}
