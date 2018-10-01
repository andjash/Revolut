//
//  Decimal+Rounding.swift
//  Revolut
//
//  Created by Andrey Yashnev on 01/10/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation


extension Decimal {
    
    var roundedCurrency: Decimal {
        var mutableSelf = self
        var rounded: Decimal = Decimal()
        NSDecimalRound(&rounded, &mutableSelf, 2, .plain)
        return rounded
    }
    
    var roundedDownCurrency: Decimal {
        var mutableSelf = self
        var rounded: Decimal = Decimal()
        NSDecimalRound(&rounded, &mutableSelf, 2, .down)
        return rounded
    }
    
}
