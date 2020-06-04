//
//  NetworkError.swift
//  AHFoundation
//
//  Created by Ahmed Sultan on 10/15/19.
// 
//

import Foundation
public enum AHNetworkResponse: String, Error {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case serverError = "server encountered an unexpected condition"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

public enum AHNetworkError: String, Error {
    case parse      = "Unable to parse response"
    case network    = "Network operation failed"
    case empty      = "Empty response"
    case missingURL = "missing URL"
    case encodingFailed = "encodingFailed"
    case unknown    = "Unknown"
    case authFailed = "Authentication token missed"
    case noInternetConnection = "no Internet Connection"
}
