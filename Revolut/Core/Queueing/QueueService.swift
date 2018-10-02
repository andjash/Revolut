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
                         completion: @escaping (T) -> (),
                         onError: @escaping (Error) -> (),
                         finally: @escaping () -> () )  {
        DispatchQueue.global(qos: .background).async {
            var result: T!
            do {
                result = try operation()
            } catch {
                DispatchQueue.main.async {
                    onError(error)
                    finally()
                }
            }
            DispatchQueue.main.async {
                completion(result)
                finally()
            }
        }
    }
}
