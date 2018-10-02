//
//  QueueServiceTests.swift
//  RevolutTests
//
//  Created by Andrey Yashnev on 02/10/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import XCTest
@testable import Revolut

class QueueServiceTests: XCTestCase {
    
    class StubError: Error {}

    func testShouldCallOperationBlock() {
        let queueService = QueueService()
        var operationCalled = false
        
        queueService.queueNetwork(operation: {
            return operationCalled = true
        }, completion: nil, onError: nil, finally: nil)
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(operationCalled)
    }
    
    func testShouldCallCompletionBlock() {
        let queueService = QueueService()
        var completionCalled = false
        
        queueService.queueNetwork(operation: {
            return ()
        }, completion: {
            completionCalled = true
        }, onError: nil, finally: nil)
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(completionCalled)
    }
    
    func testShouldCallFinallyBlock() {
        let queueService = QueueService()
        var finallyCalled = false
        
        queueService.queueNetwork(operation: {
            return ()
        }, completion: nil, onError: nil, finally: {
            finallyCalled = true
        })
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(finallyCalled)
    }
    
    func testShouldCallErrorBlock() {
        let queueService = QueueService()
        var errorCalled = false
        
        queueService.queueNetwork(operation: { () -> () in
            throw StubError()
        }, completion: nil, onError: { err in
            errorCalled = true
        }, finally: nil)
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(errorCalled)
    }
    
    func testShouldCallFinnalyAfterError() {
        let queueService = QueueService()
        var finallyCalled = false
        
        queueService.queueNetwork(operation: { () -> () in
            throw StubError()
        }, completion: nil, onError: nil, finally: {
            finallyCalled = true
        })
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(finallyCalled)
    }
    
    func testShouldNotCallCompletionAfterError() {
        let queueService = QueueService()
        var completionCalled = false
        
        queueService.queueNetwork(operation: { () -> () in
            throw StubError()
        }, completion: {
            completionCalled = true
        }, onError: nil, finally: nil)
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(!completionCalled)
    }
    
    func testShouldPassExactError() {
        let queueService = QueueService()
        let throwedError = StubError()
        var catchedError: Error?
        
        queueService.queueNetwork(operation: { () -> () in
            throw throwedError
        }, completion: nil, onError: { err in
            catchedError = err
        }, finally: nil)
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(throwedError === catchedError as? StubError)
    }
    
    func testShouldPassExactResult() {
        let queueService = QueueService()
        let passedValue = "Control"
        var catchedValue = "Test"
        
        queueService.queueNetwork(operation: {
            return passedValue
        }, completion: {
            catchedValue = $0
        }, onError: nil, finally: nil)
        RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.1))
        
        XCTAssert(passedValue == catchedValue)
    }
    

}
