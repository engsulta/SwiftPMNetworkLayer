//
//  ParameterEncoding.swift
//  AHFoundation
//
//  Created by Ahmed Sultan on 10/15/19.
// 
//

import Foundation

public protocol ParameterEncodingProtocol {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}
/// encoding url parameters into encoded query
public struct URLParameterEncoder: ParameterEncodingProtocol {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else {throw AHNetworkError.missingURL}
        guard var urlComponents = URLComponents(url: url,
                                                resolvingAgainstBaseURL: false),
                                               !parameters.isEmpty else { return }
        urlComponents.setQueryItems(with: parameters)
        urlRequest.url = urlComponents.url
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
             urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
    }
}
/// encoding body parameters to json data
public struct JSONParameterEncoder: ParameterEncodingProtocol {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw AHNetworkError.encodingFailed
        }
    }
}
/// encoding body parameters to data utf8
public struct DataParameterEncoder: ParameterEncodingProtocol {
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        var urlComponents = URLComponents()
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        urlRequest.httpBody = urlComponents.percentEncodedQuery?.data(using: .utf8)
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
    }
}
public enum AHParameterEncoder {
    case urlEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    case bodyDataEncoding

    public func encode(urlRequest: inout URLRequest,
                       bodyParameters: Parameters?,
                       urlParameters: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)

            case .jsonEncoding:
                guard let bodyParameters = bodyParameters, !bodyParameters.isEmpty else { return }
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)

            case .urlAndJsonEncoding:
                guard let bodyParameters = bodyParameters,
                    let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)

            case .bodyDataEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try DataParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
            }
        } catch {
            throw error
        }
    }
}
