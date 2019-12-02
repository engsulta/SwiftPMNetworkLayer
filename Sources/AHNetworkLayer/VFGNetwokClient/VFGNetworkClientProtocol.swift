//
//  VFGNetworkClientProtocol.swift
//  VFGFoundation
//
//  Created by Ahmed Sultan on 10/16/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation

public typealias VFGNetworkCompletion = ( Codable?, Error? ) -> Void
public typealias VFGNetworkProgressClosure = ((Double) -> Void)?
public typealias VFGNetworkDownloadClosure = ( URL?, URLResponse?, Error? ) -> Void
public protocol VFGNetworkClientProtocol {
    /// The URL of the EndPoint at the server.
    var baseUrl: String { get }
    /// A dictionary containing all the Client Related HTTP header fields (default: nil)
    var headers: [String: String]? { get }
     /// The session used during HTTP request (default: URLSession.shared)
    var session: URLSessionProtocol { get }
    /// the authClientProvider module may be injected
    var authClientProvider: AuthTokenProvider? { get set }
    /// The HTTP request timeout.
    var timeout: TimeInterval { get }
    ///start network execution to start http request
    func execute<T: Codable>(request: VFGRequestProtocol,
                             model: T.Type,
                             progressClosure: VFGNetworkProgressClosure?,
                             completion: @escaping VFGNetworkCompletion)
    func upload<T: Codable, U: Encodable>(request: VFGRequestProtocol,
                                          responseModel: T.Type,
                                          uploadModel: U,
                                          completion: @escaping VFGNetworkCompletion)
    func download(url: String,
                  progressClosure: VFGNetworkProgressClosure?,
                  completion: @escaping VFGNetworkDownloadClosure)
    func cancel(request: VFGRequestProtocol, completion: @escaping () -> Void)
}

public enum Result<NetworkError> {
    case success
    case failure(VFGNetworkResponse)
}
public protocol HTTPURLResponseProtocol {
    func handleNetworkResponse() -> Result<VFGNetworkResponse>
}
