
//
//  RatesListService.swift
//  Revolut
//
//  Created by Andrey Yashnev on 30/09/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

class RatesListService {
    
    let loadersFactory: RatesListLoaderFactory
    
    init(factory: RatesListLoaderFactory) {
        self.loadersFactory = factory
    }
    
    func getRates(withBase base: String) throws -> RatesList {
        return try loadersFactory.loader(forBaseRate: base).load()
    }
}

class RatesListLoaderFactory {
    
    let parser = CodableJsonParser<RatesList>()
    let endpointProvider: EndpointsProvider
   
    init(endpointProvider: EndpointsProvider) {
        self.endpointProvider = endpointProvider
    }
    
    func loader(forBaseRate base: String) -> Loader<RatesList> {
        let endpoint = self.endpointProvider.latestRatesListEndpoint(baseCurrency: base)
        let fetcher = PrimitiveNetworkDataFetcher(url: endpoint)
        
        return Loader(fetcher: fetcher, parser: parser)
    }
}
