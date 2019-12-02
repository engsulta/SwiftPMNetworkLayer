//
//  HTTPURLResponseExtension.swift
//  AHFoundation
//
//  Created by Ahmed Sultan on 10/17/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation

extension HTTPURLResponse: HTTPURLResponseProtocol {
    public func handleNetworkResponse() -> Result<AHNetworkResponse> {
        switch self.statusCode {
        case 200...299: return .success
        case 400:       return .failure(AHNetworkResponse.badRequest)
        case 401...499: return .failure(AHNetworkResponse.authenticationError)
        case 500...599: return .failure(AHNetworkResponse.serverError)
        case 600: return .failure(AHNetworkResponse.outdated)
        default: return .failure(AHNetworkResponse.failed)
        }
    }
}
