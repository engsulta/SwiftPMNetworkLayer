//
//  AuthTokenProvider.swift
//  AHFoundation
//
//  Created by Esraa Eldaltony on 10/17/19.
// 
//

import Foundation

public typealias Success = ([String: String]?, Error?) -> Void
// this protocol with be used by the network layer to use the authentication token when needed.
public protocol AuthTokenProvider {
    // request token
    func requestAuthToken(closure: @escaping Success)
}
