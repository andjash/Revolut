//
//  QueueService.swift
//  Revolut
//
//  Created by Andrey Yashnev on 02/10/2018.
//  Copyright © 2018 andjash. All rights reserved.
//

import Foundation

class QueueService {
    
    func queueNetwork<T>(operation: @escaping () throws -> T,
                         completion: ((T) -> ())?,
                         onError: ((Error) -> ())?,
                         finally: (() -> ())? )  {
        DispatchQueue.global(qos: .background).async {
            do {
                let result = try operation()
                DispatchQueue.main.async {
                    completion?(result)
                    finally?()
                }
            } catch {
                DispatchQueue.main.async {
                    onError?(error)
                    finally?()
                }
            }
        }
    }
    
    func execute(operation: @escaping ( @escaping () -> ()) -> (), withPeriod period: TimeInterval, untilAlive monitor: AnyObject) {
        weak var weakMonitor = monitor
        weak var wself = self
        operation({
            DispatchQueue.main.asyncAfter(deadline: .now() + period) {
                guard let sself = wself else { return }
                guard let smonitor = weakMonitor else { return }
                sself.execute(operation: operation, withPeriod: period, untilAlive: smonitor)
            }
        })
      
        
    }
}
