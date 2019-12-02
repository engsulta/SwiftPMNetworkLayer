//
//  AHNetworkClientProtocol.swift
//  AHFoundation
//
//  Created by Ahmed Sultan on 10/16/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation

public typealias AHNetworkCompletion = ( Codable?, Error? ) -> Void
public typealias AHNetworkProgressClosure = ((Double) -> Void)?
public typealias AHNetworkDownloadClosure = ( URL?, URLResponse?, Error? ) -> Void
public protocol AHNetworkClientProtocol {
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
    func execute<T: Codable>(request: AHRequestProtocol,
                             model: T.Type,
                             progressClosure: AHNetworkProgressClosure?,
                             completion: @escaping AHNetworkCompletion)
    func upload<T: Codable, U: Encodable>(request: AHRequestProtocol,
                                          responseModel: T.Type,
                                          uploadModel: U,
                                          completion: @escaping AHNetworkCompletion)
    func download(url: String,
                  progressClosure: AHNetworkProgressClosure?,
                  completion: @escaping AHNetworkDownloadClosure)
    func cancel(request: AHRequestProtocol, completion: @escaping () -> Void)
}

public enum Result<NetworkError> {
    case success
    case failure(AHNetworkResponse)
}
public protocol HTTPURLResponseProtocol {
    func handleNetworkResponse() -> Result<AHNetworkResponse>
}
