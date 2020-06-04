//
//  URLComponents+Encoding.swift
//  AHFoundation
//
//  Created by Ahmed Sultan on 10/15/19.
// 
//

import Foundation

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: Any]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key,
                                                        value: "\($0.value)")
        }
    }
}
