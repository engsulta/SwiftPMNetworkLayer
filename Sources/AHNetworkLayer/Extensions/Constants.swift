//
//  Constants.swift
//  AHFoundation
//
//  Created by Ahmed Sultan on 10/17/19.
// 
//

import Foundation

public struct NetworkDefaults {
    public static let timeOut: TimeInterval = 10
    public static let httpMethod: HTTPMethod = .get
    public static let httpTask: HTTPTask = .request
    public static let httpHeaders: HTTPHeaders? = nil
    public static let cashPolicy: CachePolicy = .reloadIgnoringLocalCacheData
    public static let isAuthenticationNeeded: Bool = true
    public static let path: String = ""
    public static let workerQueue: DispatchQueue = DispatchQueue.global(qos: .default)
}
