//
//  NumberFormatter.swift
//  Revolut
//
//  Created by Andrey Yashnev on 03/10/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation


extension NumberFormatter {
    
    static func rv_defaultCurrencyNumberFormatter() -> NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumIntegerDigits = 13
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.roundingMode = .down
        return numberFormatter
    }
    
}
