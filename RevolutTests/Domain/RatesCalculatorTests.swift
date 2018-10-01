
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
        let rubRate = Decimal(80)
        let usdRate = Decimal(1.2)
        let usdAmount = Decimal(1)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        let control = (usdAmount / usdRate) * rubRate
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: usdAmount)
        
        XCTAssert(test == control)
    }
    
    func testDirectRateProperlyCalculated() {
        let rubRate = Decimal(80)
        let usdRate = Decimal(1.2)
        let eurAmount = Decimal(1.5)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        let control = eurAmount * rubRate
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "EUR", amount: eurAmount)
        
        XCTAssert(test == control)
    }
    
    func testNotExistingCrossCurrencyIsNotCalculated() {
        let rubRate = Decimal(80)
        let usdRate = Decimal(1.2)
        let eurAmount = Decimal(1.5)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "SOME", amount: eurAmount)
        
        XCTAssert(test == nil)
    }
    
    func testNotExistingTargetCurrencyIsNotCalculated() {
        let rubRate = Decimal(80)
        let usdRate = Decimal(1.2)
        let eurAmount = Decimal(1.5)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "SOME", withOther: "EUR", amount: eurAmount)
        
        XCTAssert(test == nil)
    }
    
    func testZeroAmountProperlyCalculated() {
        let rubRate = Decimal(80)
        let usdRate = Decimal(1.2)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "EUR", amount: Decimal(0))
        
        XCTAssert(test == Decimal(0))
    }
    
    func testSameCurrencyReturnsSame() {
        let rubRate = Decimal(80)
        let usdRate = Decimal(1.2)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        let control = Decimal(33.5423)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "RUB", amount: control)
        
        XCTAssert(test == control)
    }
    
    func testReturnsNilIfCrossAmountIsNan() {
        let rubRate = Decimal(80)
        let usdRate = Decimal(1.2)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: Decimal.nan)
        
        XCTAssert(test == nil)
    }
    
    func testReturnsNilIfCrossRateIsNan() {
        let rubRate = Decimal(80)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : Decimal.nan]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: Decimal(1))
        
        XCTAssert(test == nil)
    }
    
    func testReturnsNilIfTargetRateIsNan() {
        let usdRate = Decimal(80)
        
        let base = "EUR"
        let rates = ["RUB" : Decimal.nan, "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: Decimal(1))
        
        XCTAssert(test == nil)
    }
    
    func testReturnsNilIfCrossRateIsZero() {
        let rubRate = Decimal(80)
        
        let base = "EUR"
        let rates = ["RUB" : rubRate, "USD" : Decimal(0)]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: Decimal(1))
        
        XCTAssert(test == nil)
    }
    
    func testReturnsZeroIfTargetRateIsZero() {
        let usdRate = Decimal(80)
        
        let base = "EUR"
        let rates = ["RUB" : Decimal(0), "USD" : usdRate]
        let calculator = RatesCalculator(base: base, rates: rates)
        
        let test = calculator.amount(ofCurrency: "RUB", withOther: "USD", amount: Decimal(1))
        
        XCTAssert(test == Decimal(0))
    }
    
}


