//
//  Decimal+Rounding.swift
//  Revolut
//
//  Created by Andrey Yashnev on 01/10/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation


extension Decimal {
    
    var rv_roundedCurrency: Decimal {
        var mutableSelf = self
        var rounded: Decimal = Decimal()
        NSDecimalRound(&rounded, &mutableSelf, 2, .bankers)
        return rounded
    }
    
    var rv_roundedDownCurrency: Decimal {
        var mutableSelf = self
        var rounded: Decimal = Decimal()
        NSDecimalRound(&rounded, &mutableSelf, 2, .down)
        return rounded
    }
    
}
