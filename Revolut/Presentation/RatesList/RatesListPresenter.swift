//
//  RatesListPresenter.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

protocol RatesListPresenterDelegate: class {
    func display(data: [RatesListPresenter.DataEntry])
    func focusEntry(atIndex: Int, allData: [RatesListPresenter.DataEntry])
}

class RatesListPresenter {
    
    struct DataEntry {
        let currencyName: String
        let value: String
    }
    
    private struct Origin {
        let amount: Decimal
        let currency: String
        let displayValue: String
    }
    
    private var data: [DataEntry] = []
    private var origin: Origin
    private var ratesCalculator: RatesCalculator
    
    private let rateListService: RatesListService
    private let baseCurrency: String
    private let numberFormatter: NumberFormatter
    
    weak var delegate: RatesListPresenterDelegate?
    
    init(rateListService: RatesListService, baseCurrency: String) {
        self.rateListService = rateListService
        self.baseCurrency = baseCurrency
        
        ratesCalculator = RatesCalculator(base: baseCurrency, rates: [:])
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.roundingMode = .down
        
        origin = Origin(amount: Decimal(floatLiteral: 1), currency: baseCurrency, displayValue: numberFormatter.string(from: NSDecimalNumber.one) ?? "1")
    }
    
    // MARK - Input
    
    func viewIsReady() {
        loadData()
    }
    
    func didStartEditing(forEntry entry: DataEntry, atIndex index: Int) {
        data = [entry] + data.filter { $0.currencyName != entry.currencyName }
        delegate?.focusEntry(atIndex: index, allData: data)
    }
    
    func didEditValue(forEntry: DataEntry, newValue: String) {
        let preparedString = newValue.replacingOccurrences(of: numberFormatter.groupingSeparator, with: "")
        var number = numberFormatter.number(from: preparedString) as? Decimal ?? Decimal(0)
        if number.isNaN {
            number = Decimal(0)
        }

        var displayValue = numberFormatter.string(from: number as NSDecimalNumber) ?? "0"
        if newValue.hasSuffix(numberFormatter.decimalSeparator) {
            displayValue += numberFormatter.decimalSeparator
        }
        
        let roundedNumber = numberFormatter.number(from: displayValue) as? Decimal ?? Decimal(0)
        
        origin = Origin(amount: roundedNumber, currency: forEntry.currencyName, displayValue: displayValue)
        data = recalculate(oldData: data, calculator: ratesCalculator, origin: origin)
        delegate?.display(data: data)
    }
    
    // MARK: - Private

    private func loadData() {
        let latestOrigin = origin
        DispatchQueue.global(qos: .background).async {
            let ratesList = try! self.rateListService.getRates(withBase: self.baseCurrency)
            let newCalculator = RatesCalculator(base: ratesList.base, rates: ratesList.rates)
            let newData = self.createNewData(calculator: newCalculator, origin: latestOrigin)
                
                DispatchQueue.main.async {
                    self.data = newData
                    self.ratesCalculator = newCalculator
                    self.delegate?.display(data: newData)
                }
        }
    }
    
    private func createNewData(calculator: RatesCalculator, origin: Origin) -> [DataEntry] {
        return calculator.rates.map { tuple in
            var calculatedValueString: String?
            if let value = calculator.amount(ofCurrency: tuple.key, withOther: origin.currency, amount: origin.amount) {
                calculatedValueString = numberFormatter.string(from: value as NSDecimalNumber)
            }
            
            return DataEntry(currencyName: tuple.key, value: calculatedValueString ?? "0")
        }.sorted(by: { (l, r) -> Bool in
            return l.currencyName < r.currencyName
        })
    }
    
    private func recalculate(oldData: [DataEntry], calculator: RatesCalculator, origin: Origin) -> [DataEntry] {
        return oldData.map { entry in
            var calculatedValueString: String?
            if entry.currencyName == origin.currency {
                calculatedValueString = origin.displayValue
            } else {
                if let value = calculator.amount(ofCurrency: entry.currencyName, withOther: origin.currency, amount: origin.amount) {
                    calculatedValueString = numberFormatter.string(from: value as NSDecimalNumber)
                }
            }
            return DataEntry(currencyName: entry.currencyName, value: calculatedValueString ?? "0")
        }
    }
}
