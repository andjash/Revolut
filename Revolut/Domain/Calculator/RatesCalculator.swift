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
    
    init(base: String, rates: [String : Decimal]) {
        self.base = base
        self.rates = rates
    }
    
    func amount(ofCurrency target: String, withOther crossCurrency: String, amount crossAmount: Decimal) -> Decimal? {
        var crossCurrencyRate: Decimal!
        
        if crossCurrency == base {
            crossCurrencyRate = Decimal(integerLiteral: 1)
        } else if target == crossCurrency {
            return crossAmount.rv_roundedCurrency
        } else {
            crossCurrencyRate = rates[crossCurrency]
        }
        
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
        
        let amountOfBase = (crossAmount / crossCurrencyRate).rv_roundedCurrency
        return (amountOfBase * targetCurrencyRate).rv_roundedCurrency
    }
    
    
}
