//
//  VFGNetworkClient.swift
//  VFGFoundation
//
//  Created by Ahmed Sultan on 10/17/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation
public typealias CurrentTask = (request: VFGRequestProtocol?, task: URLSessionDataTaskProtocol?)
// Exposed Network Client that will be inherited
open class VFGNetworkClient: VFGNetworkClientProtocol {
    internal weak var networkProgressDelegate: VFGNetworkProgressDelegate? {
        return session.sessionDelegate
    }
    public var runningTasks: [CurrentTask] = []
    public var timeout: TimeInterval { return NetworkDefaults.timeOut }
    public var baseUrl: String
    public var headers: [String: String]? { return nil }
    public var session: URLSessionProtocol
    public var authClientProvider: AuthTokenProvider?
    public init(baseURL: String, session: URLSessionProtocol = URLSession.shared) {
        self.baseUrl = baseURL
        self.session = session
    }
}
