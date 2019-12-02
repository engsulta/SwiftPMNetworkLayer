//
//  URLComponents+Encoding.swift
//  VFGFoundation
//
//  Created by Ahmed Sultan on 10/15/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: Any]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key,
                                                        value: "\($0.value)")
        }
    }
}
