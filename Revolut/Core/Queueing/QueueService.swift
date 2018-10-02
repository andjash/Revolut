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
}
