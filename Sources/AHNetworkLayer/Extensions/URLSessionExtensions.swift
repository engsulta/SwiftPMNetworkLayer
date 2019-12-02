//
//  URLSessionExtensions.swift
//  VFGFoundation
//
//  Created by Ahmed Sultan on 10/17/19.
//  Copyright © 2019 Vodafone. All rights reserved.
//

import Foundation
public protocol URLSessionTaskProtocol {}
public protocol URLSessionDataTaskProtocol {
    func resume()
    func suspend()
    func cancel()
}
public protocol URLSessionUploadTaskProtocol {
    func resume()
    func cancel()
}
public protocol URLSessionDownloadTaskProtocol {
    func resume()
    func cancel()
}
extension URLSessionTask: URLSessionTaskProtocol {}
extension URLSessionUploadTask: URLSessionUploadTaskProtocol {}
extension URLSessionDownloadTask: URLSessionDownloadTaskProtocol {}
extension URLSessionDataTask: URLSessionDataTaskProtocol {}

public protocol URLSessionProtocol {
    var sessionDelegate: VFGNetworkProgressDelegate? { get }
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    typealias DownloadTaskResult = (URL?, URLResponse?, Error?) -> Void
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
    func dataTask(with url: URL, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
    func uploadTask(with request: URLRequest,
                    from data: Data,
                    completionHandler: @escaping DataTaskResult) -> URLSessionUploadTaskProtocol
    func downloadTask(with url: URL, completionHandler: @escaping DownloadTaskResult) -> URLSessionDownloadTaskProtocol
}
/// default implementation for tasks so you do not need to implement extra methods in your session 
extension URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        completionHandler(nil, nil, nil)
        return URLSessionUploadTask()
    }
    func dataTask(with url: URL,
                  completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        completionHandler(nil, nil, nil)
        return URLSessionUploadTask()
    }
    func downloadTask(with url: URL,
                      completionHandler: @escaping DownloadTaskResult) -> URLSessionDownloadTaskProtocol {
         completionHandler(nil, nil, nil)
         return URLSessionDownloadTask()
    }
    func uploadTask(with request: URLRequest,
                    from data: Data,
                    completionHandler: @escaping DataTaskResult) -> URLSessionUploadTaskProtocol {
        completionHandler(nil, nil, nil)
        return URLSessionUploadTask()
    }
}
extension URLSession: URLSessionProtocol {
    public var sessionDelegate: VFGNetworkProgressDelegate? {
        return delegate as? VFGNetworkProgressDelegate
    }
    public func downloadTask(with url: URL,
                             completionHandler: @escaping DownloadTaskResult) -> URLSessionDownloadTaskProtocol {
         return downloadTask(with: url, completionHandler: completionHandler) as URLSessionDownloadTask
    }
    public func dataTask(with url: URL,
                         completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask
    }
    public func uploadTask(with request: URLRequest,
                           from data: Data,
                           completionHandler: @escaping DataTaskResult) -> URLSessionUploadTaskProtocol {
    return uploadTask(with: request,
                      from: data,
                      completionHandler: completionHandler) as URLSessionUploadTask
    }
    public func dataTask(with request: URLRequest,
                         completionHandler: @escaping DataTaskResult)
        -> URLSessionDataTaskProtocol {
            return dataTask(with: request,
                            completionHandler: completionHandler) as URLSessionDataTask
    }
}
