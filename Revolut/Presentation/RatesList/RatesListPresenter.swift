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
    func display(error: String)
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
    
    private let rateListService: RatesListService
    private let baseCurrency: String
    private let queueService: QueueService
    
    private var data: [DataEntry] = []
    private var origin: Origin
    private var ratesCalculator: RatesCalculator
    private let numberFormatter: NumberFormatter
    
    weak var delegate: RatesListPresenterDelegate?
    var updatePeriod: TimeInterval = 3
    
    init(rateListService: RatesListService, queueService: QueueService, baseCurrency: String) {
        self.rateListService = rateListService
        self.baseCurrency = baseCurrency
        self.queueService = queueService
        
        ratesCalculator = RatesCalculator(base: baseCurrency, rates: [:])
        numberFormatter = NumberFormatter.rv_defaultDecimalNumberFormatter()
        
        origin = Origin(amount: Decimal(floatLiteral: 1), currency: baseCurrency, displayValue: numberFormatter.string(from: NSDecimalNumber.one) ?? "1")
    }
    
    // MARK - Input
    
    func viewIsReady() {
        queueService.execute(operation: { [weak self] scheduleNext in
            self?.loadData(completion: scheduleNext)
        }, withPeriod: updatePeriod, untilAlive: self)
    }
    
    func didStartEditing(forEntry entry: DataEntry, atIndex index: Int) {
        data = [entry] + data.filter { $0.currencyName != entry.currencyName }
        delegate?.focusEntry(atIndex: index, allData: data)
    }
    
    func didEditValue(forEntry: DataEntry, newValue: String) {
        let preparedString = newValue.replacingOccurrences(of: numberFormatter.groupingSeparator, with: "")
        var number = (Decimal(string: preparedString) ?? Decimal(0)).rv_roundedDownCurrency
        if number.isNaN {
            number = Decimal(0)
        }

        var displayValue = numberFormatter.string(from: number as NSDecimalNumber) ?? "0"
        let restrictedNUmber = numberFormatter.number(from: displayValue) as? Decimal ?? Decimal(0)
        
        
        let decimalParts = newValue.components(separatedBy: numberFormatter.decimalSeparator).filter { $0.count > 0 }
        if newValue.hasSuffix(numberFormatter.decimalSeparator) && decimalParts.count == 1 {
            displayValue += numberFormatter.decimalSeparator
        }
      
        origin = Origin(amount: restrictedNUmber, currency: forEntry.currencyName, displayValue: displayValue)
        data = recalculate(oldData: data, calculator: ratesCalculator, origin: origin)
        delegate?.display(data: data)
    }
    
    // MARK: - Private

    private func loadData(completion: @escaping () -> ()) {
        let latestOrigin = origin
        
        weak var wself = self
        queueService.queueNetwork(operation: { () -> (RatesCalculator) in
            let ratesList = try self.rateListService.getRates(withBase: self.baseCurrency)
            var rates = ratesList.rates
            rates[ratesList.base] = Decimal(1)
            
            return RatesCalculator(base: ratesList.base, rates: rates)
        }, completion: { newCalculator in
            guard let `self` = wself else { return }
            let newRatesData = self.createNewData(calculator: newCalculator, origin: latestOrigin)
            let mergedData = self.merge(newData: newRatesData, oldData: self.data, origin: self.origin)
            self.data = mergedData
            self.ratesCalculator = newCalculator
            self.delegate?.display(data: mergedData)
        }, onError: { error in
            guard let `self` = wself else { return }
            self.delegate?.display(error: "Unable to load data")
        }, finally: completion)
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
    
    private func merge(newData: [DataEntry], oldData: [DataEntry], origin: Origin) -> [DataEntry] {
        let oldCurrenciesSet = Set(oldData.map { $0.currencyName })
        let newWithoutOld = newData.filter { !oldCurrenciesSet.contains($0.currencyName) }
        
        var newCurrenciesDict: [String : String] = [:]
        newData.forEach {
            if $0.currencyName == origin.currency {
                return
            }
            newCurrenciesDict[$0.currencyName] = $0.value
        }
        let oldWithNewValues = oldData.map { DataEntry(currencyName: $0.currencyName, value: newCurrenciesDict[$0.currencyName] ?? $0.value) };
        
        return oldWithNewValues + newWithoutOld
    }
    
}
