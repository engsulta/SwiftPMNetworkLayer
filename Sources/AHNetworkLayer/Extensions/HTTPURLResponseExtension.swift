//
//  HTTPURLResponseExtension.swift
//  VFGFoundation
//
//  Created by Ahmed Sultan on 10/17/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation

extension HTTPURLResponse: HTTPURLResponseProtocol {
    public func handleNetworkResponse() -> Result<VFGNetworkResponse> {
        switch self.statusCode {
        case 200...299: return .success
        case 400:       return .failure(VFGNetworkResponse.badRequest)
        case 401...499: return .failure(VFGNetworkResponse.authenticationError)
        case 500...599: return .failure(VFGNetworkResponse.serverError)
        case 600: return .failure(VFGNetworkResponse.outdated)
        default: return .failure(VFGNetworkResponse.failed)
        }
    }
}
