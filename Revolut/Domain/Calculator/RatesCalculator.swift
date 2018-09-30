//
//  RatesCalculator.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

class RatesCalculator {
    
    let base: String
    let rates: [String : NSDecimalNumber]
    
    private let decimalHandler: NSDecimalNumberHandler
    
    init(base: String, rates: [String : NSDecimalNumber]) {
        self.base = base
        self.rates = rates
        
        let defaultHandler = NSDecimalNumberHandler.default
        decimalHandler = NSDecimalNumberHandler(roundingMode: defaultHandler.roundingMode(),
                                                scale: defaultHandler.scale(),
                                                raiseOnExactness: false,
                                                raiseOnOverflow: false,
                                                raiseOnUnderflow: false,
                                                raiseOnDivideByZero: false)
    }
    
    func amount(ofCurrency target: String, withOther crossCurrency: String, amount crossAmount: NSDecimalNumber) -> NSDecimalNumber? {
        var crossCurrencyRate: NSDecimalNumber!
        
        if crossCurrency == base {
            crossCurrencyRate = NSDecimalNumber.one
        } else {
            crossCurrencyRate = rates[crossCurrency]
        }
        
        guard crossCurrencyRate != nil else {
            return nil
        }
        
        guard let targetCurrencyRate = rates[target] else {
            return nil
        }
        
        let amountOfBase = crossAmount.dividing(by: crossCurrencyRate, withBehavior: decimalHandler)
        let result = amountOfBase.multiplying(by: targetCurrencyRate, withBehavior: decimalHandler)
        return result == NSDecimalNumber.notANumber ? nil : result
    }
    
    
}
