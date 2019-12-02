//
//  VFGRequestProtocol.swift
//  VFGFoundation
//
//  Created by Atta Amed on 10/23/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]
public typealias HTTPHeaders = [String: String]
public typealias CachePolicy = URLRequest.CachePolicy
public enum DataType {
    case json
    case data
}
/**
 Network Generic EndPoint protocol used By business layer to create network Requests.
 */
public protocol VFGRequestProtocol {
    /// The relative Endpoint path added to baseUrl
    var path: String {get}
    /// The HTTP request method
    var httpMethod: HTTPMethod {get}
    /// Http task create encoded data sent as the message body of a request, such as for an HTTP POST request or
    /// inline in case of HTTP GET request (default: .request)
    var httpTask: HTTPTask {get}
    /// A dictionary containing all the request’s HTTP header fields related to such endPoint(default: nil)
    var headers: HTTPHeaders? {get}
    /// authentication Flag if exist in protocol network client may ask auth layer to provide new auth token
    var isAuthenticationNeededRequest: Bool? {get}
    ///The constants enum used to specify interaction with the cached responses.
    /** Specifies that the caching logic defined in the protocol implementation, if any, is
     used for a particular URL load request. This is the default policy
     for URL load requests.*/
    var cachePolicy: CachePolicy { get }
}

extension VFGRequestProtocol {
    // internal hash for network foundation so that it can cancel your request
    internal var hash: Int {
        var hasher = Hasher()
        hasher.combine(path)
        hasher.combine(headers)
        hasher.combine(cachePolicy)
        hasher.combine(isAuthenticationNeededRequest)
        hasher.combine(httpMethod)
        hasher.combine(httpTask)
        return hasher.finalize()
    }
}

public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
    case options = "OPTIONS"
}

public enum HTTPTask {
    case request
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: VFGParameterEncoder,
        urlParameters: Parameters?)
    case requestParametersAndHeaders(bodyParameters: Parameters?, bodyEncoding: VFGParameterEncoder,
        urlParameters: Parameters?,
        extraHeaders: HTTPHeaders?)
}
extension HTTPTask: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
    public static func == (lhs: HTTPTask, rhs: HTTPTask) -> Bool {
       return lhs.hash == rhs.hash
    }
    internal var hash: Int {
        switch self {
        case .request:
            var hasher = Hasher()
            hasher.combine("request")
            return hasher.finalize()
        case .requestParameters(let bodyParameters, let bodyEncoding, let urlParameters):
            var hasher = Hasher()
            hasher.combine(bodyParameters as? [String: String])
            hasher.combine(bodyEncoding)
            hasher.combine(urlParameters as? [String: String])
            return hasher.finalize()
        case .requestParametersAndHeaders(let bodyParameters, let bodyEncoding, let urlParameters, let extraHeaders):
            var hasher = Hasher()
            hasher.combine(bodyParameters as? [String: String])
            hasher.combine(bodyEncoding)
            hasher.combine(urlParameters as? [String: String])
            hasher.combine(extraHeaders)
            return hasher.finalize()
        }
    }
}
// VFRequest is the concrete impletation that can be initialized using biulder
public struct VFGRequest: VFGRequestProtocol {
    public var httpMethod: HTTPMethod
    public var httpTask: HTTPTask
    public var headers: HTTPHeaders?
    public var isAuthenticationNeededRequest: Bool?
    public var cachePolicy: CachePolicy
    public var path: String
    public init(path: String = NetworkDefaults.path,
                httpMethod: HTTPMethod = NetworkDefaults.httpMethod,
                httpTask: HTTPTask = NetworkDefaults.httpTask,
                headers: HTTPHeaders? = NetworkDefaults.httpHeaders,
                isAuthenticationNeededRequest: Bool? = NetworkDefaults.isAuthenticationNeeded,
                cachePolicy: CachePolicy = NetworkDefaults.cashPolicy) {
        self.path = path
        self.httpMethod = httpMethod
        self.httpTask = httpTask
        self.headers = headers
        self.isAuthenticationNeededRequest = isAuthenticationNeededRequest
        self.cachePolicy = cachePolicy
    }
}
