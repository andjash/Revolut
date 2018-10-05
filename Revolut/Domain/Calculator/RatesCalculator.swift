//
//  RatesCalculator.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

class RatesCalculator {
    
    let rates: [String : Decimal]
    
    init(rates: [String : Decimal]) {
        self.rates = rates
    }
    
    func amount(ofCurrency target: String, withOther crossCurrency: String, amount crossAmount: Decimal) -> Decimal? {
        guard target != crossCurrency else {
            return crossAmount.rv_roundedCurrency
        }
        
        guard  let crossCurrencyRate = rates[crossCurrency] else {
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
