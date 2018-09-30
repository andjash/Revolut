
//
//  RatesCalculatorTests.swift
//  RevolutTests
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import XCTest
@testable import Revolut

class RatesCalculatorTests: XCTestCase {
    
    func testCrossCurrencyProperlyCalculated() {
        let rubRate = NSDecimalNumber(string: "80")
        let usdRate = NSDecimalNumber(string: "1.2")
        let usdAmount = NSDecimalNumber(string: "1")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        let control = usdAmount.dividing(by: usdRate).multiplying(by: rubRate)
        
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: usdAmount)
        
        XCTAssert(test == control)
    }
    
    func testDirectRateProperlyCalculated() {
        let rubRate = NSDecimalNumber(string: "80")
        let usdRate = NSDecimalNumber(string: "1.2")
        let eurAmount = NSDecimalNumber(string: "1.5")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        let control = eurAmount.multiplying(by: rubRate)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "EUR", amount: eurAmount)
        
        XCTAssert(test == control)
    }
    
    func testNotExistingCrossCurrencyIsNotCalculated() {
        let rubRate = NSDecimalNumber(string: "80")
        let usdRate = NSDecimalNumber(string: "1.2")
        let eurAmount = NSDecimalNumber(string: "1.5")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "SOME", amount: eurAmount)
        
        XCTAssert(test == nil)
    }
    
    func testNotExistingTargetCurrencyIsNotCalculated() {
        let rubRate = NSDecimalNumber(string: "80")
        let usdRate = NSDecimalNumber(string: "1.2")
        let eurAmount = NSDecimalNumber(string: "1.5")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "SOME", withOther: "EUR", amount: eurAmount)
        
        XCTAssert(test == nil)
    }
    
    func testZeroAmountProperlyCalculated() {
        let rubRate = NSDecimalNumber(string: "80")
        let usdRate = NSDecimalNumber(string: "1.2")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "EUR", amount: NSDecimalNumber.zero)
        
        XCTAssert(test == NSDecimalNumber.zero)
    }
    
    func testSameCurrencyReturnsSame() {
        let rubRate = NSDecimalNumber(string: "80")
        let usdRate = NSDecimalNumber(string: "1.2")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        let control = NSDecimalNumber(string: "33.5423")
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "RUB", amount: control)
        
        XCTAssert(test == control)
    }
    
    func testReturnsNilIfCrossAmountIsNan() {
        let rubRate = NSDecimalNumber(string: "80")
        let usdRate = NSDecimalNumber(string: "1.2")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: NSDecimalNumber.notANumber)
        
        XCTAssert(test == nil)
    }
    
    func testReturnsNilIfCrossRateIsNan() {
        let rubRate = NSDecimalNumber(string: "80")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : NSDecimalNumber.notANumber]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: NSDecimalNumber.one)
        
        XCTAssert(test == nil)
    }
    
    func testReturnsNilIfTargetRateIsNan() {
        let usdRate = NSDecimalNumber(string: "80")
        
        let base = "EUR"
        let rates = ["RUB" : NSDecimalNumber.notANumber, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: NSDecimalNumber.one)
        
        XCTAssert(test == nil)
    }
    
    func testReturnsNilIfCrossRateIsZero() {
        let rubRate = NSDecimalNumber(string: "80")
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : NSDecimalNumber.zero]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: NSDecimalNumber.one)
        
        XCTAssert(test == nil)
    }
    
    func testReturnsZeroIfTargetRateIsZero() {
        let usdRate = NSDecimalNumber(string: "80")
        
        let base = "EUR"
        let rates = ["RUB" : NSDecimalNumber.zero, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: NSDecimalNumber.one)
        
        XCTAssert(test == NSDecimalNumber.zero)
    }
    
}


