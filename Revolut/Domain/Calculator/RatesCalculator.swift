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
    let rates: [String : Decimal]
    
    private let decimalHandler: NSDecimalNumberHandler
    
    init(base: String, rates: [String : Decimal]) {
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
    
    func amount(ofCurrency target: String, withOther crossCurrency: String, amount crossAmount: Decimal) -> Decimal? {
        var crossCurrencyRate: Decimal!
        
        if crossCurrency == base {
            crossCurrencyRate = Decimal(integerLiteral: 1)
        } else {
            crossCurrencyRate = rates[crossCurrency]
        }
        7
        guard crossCurrencyRate != nil else {
            return nil
        }
        
        guard let targetCurrencyRate = rates[target] else {
            return nil
        }
        
        guard !crossCurrencyRate.isZero,
            !crossAmount.isNaN,
            !crossCurrencyRate.isNaN,
            !targetCurrencyRate.isNaN else {
            return nil
        }
        
        let amountOfBase = crossAmount / crossCurrencyRate
        let result = amountOfBase * targetCurrencyRate
        return result
    }
    
    
}
