//
//  AHNetworkClientDefaultExtensions.swift
//  AHFoundation
//
//  Created by Ahmed Sultan on 10/17/19.
// 
//

import Foundation
public typealias ResponseArg = (data: Data?, urlResponse: URLResponse?, error: Error?)
public typealias ResponseCompletionHandler = (ResponseArg) -> Void
/**
 this extension give a default implementation for execute network
 call it accept type VFRequestType else you can build your own implementation with different request type
 */
extension AHNetworkClient {
    @discardableResult
    open func execute<T: Codable>(request: AHRequestProtocol,
                                  model: T.Type,
                                  progressClosure: AHNetworkProgressClosure? = nil,
                                  completion: @escaping AHNetworkCompletion) -> T? {
        // the response handler that will be executed once network response recieved
        let responseCompletionHandler: (Data?,URLResponse?, Error?) -> Void = { [weak self] (data, res, error) in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(nil, AHNetworkError.network)
                }
                return
            }
            let arg: (data: Data?, urlResponse: URLResponse?, error: Error?) = (data, res, error)
            self.mapResponse(responseArg: arg, model: model, completion: completion)
        }
        // to check if local file data task or network request data task
        do {
            let currentTask: URLSessionDataTaskProtocol
            let isRequestPathFile = URL(string: request.path)?.isFileURL ?? false
            let fileURL = isRequestPathFile ? URL(string: request.path): URL(string: baseUrl)
            if let baseURL = fileURL, baseURL.isFileURL {
                 currentTask = session.dataTask(with: baseURL, completionHandler: responseCompletionHandler)

            } else {
                let fullRequestHeaders = buildHeaders(request: request, completion: completion)
                let urlRequest = try buildRequest(from: request, with: fullRequestHeaders, to: URL(string: baseUrl))
                AHNetworkLogger.log(request: urlRequest)
                currentTask = session.dataTask(with: urlRequest, completionHandler: responseCompletionHandler)
            }

            currentTask.resume()
            networkProgressDelegate?.addTask(dataTask: currentTask, progressClosure: progressClosure)
            NetworkDefaults.workerQueue.sync {
                self.runningTasks.append(CurrentTask(request: request, task: currentTask))
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil, AHNetworkError.unknown)}
        }
        if request.cache ?? false {
            let path = request.path.replacingOccurrences(of: "/", with: "_")
            if let data = AHCachingManager.shared.readData(from: path) {
               return try? JSONDecoder().decode(model, from: data)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    open func cancel(request: AHRequestProtocol, completion: @escaping () -> Void) {
        let cancelledTaskIndex = runningTasks.firstIndex { $0.request?.hash == request.hash}

        guard let taskIndex = cancelledTaskIndex else { return }
        NetworkDefaults.workerQueue.async(qos: .default, flags: .barrier) {
            self.runningTasks.remove(at: taskIndex).task?.cancel()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
/// upload default implementation
extension AHNetworkClient {
    open func upload<T: Codable, U: Encodable>(request: AHRequestProtocol,
                                               responseModel: T.Type,
                                               uploadModel: U,
                                               completion: @escaping AHNetworkCompletion) {
        let fullRequestHeaders = buildHeaders(request: request, completion: completion)
        do {
            let urlRequest = try buildRequest(from: request, with: fullRequestHeaders, to: URL(string: baseUrl))
            AHNetworkLogger.log(request: urlRequest)
            let uploadModeldata = try JSONEncoder().encode(uploadModel)
            let currentTask = session.uploadTask(with: urlRequest,
                                                 from: uploadModeldata) { [weak self] (data, response, error) in
                                                    let resType: ResponseArg = (data, response, error)
                                                    guard let self = self else {
                                                        return
                                                    }
                                                    self.mapResponse(responseArg: resType,
                                                                     model: responseModel,
                                                                     completion: completion)
            }
            currentTask.resume()
        } catch {
            DispatchQueue.main.async {
                completion(nil, AHNetworkError.unknown)}
        }
    }
}
/// download file simple implementation
extension AHNetworkClient {
    public func download(url: String,
                         progressClosure: AHNetworkProgressClosure? = nil,
                         completion: @escaping AHNetworkDownloadClosure) {
        let currentTask: URLSessionDownloadTaskProtocol
        let baseURL = URL(string: url)

        if let baseURL = baseURL {
            currentTask = session.downloadTask(with: baseURL) { (location, response, error) in
                DispatchQueue.main.async {
                    completion(location, response, error)
                }
            }
            currentTask.resume()
            networkProgressDelegate?.addTask(downloadTask: currentTask, progressClosure: progressClosure)
        }
    }
}
// this extension for mapping the response
extension AHNetworkClient {
    open func decodeJsonData<T: Codable>(_ responseData: Data,
                                         _ model: T.Type,
                                         _ completion: @escaping AHNetworkCompletion) {
        do {
            let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
            AHNetworkLogger.log(jsonResponse: jsonData)
            let apiResponse = try JSONDecoder().decode(model, from: responseData)
            DispatchQueue.main.async {
                completion(apiResponse, nil)
                AHNetworkLogger.log(jsonResponse: apiResponse)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil, AHNetworkResponse.unableToDecode)}
        }
    }
    open func mapResponse<T: Codable>(responseArg: ResponseArg,
                                      model: T.Type,
                                      completion: @escaping AHNetworkCompletion) {
        guard responseArg.error == nil else {
            DispatchQueue.main.async {
                completion(nil, responseArg.error)
            }
            return
        }
        guard  let httpResponse = responseArg.urlResponse as? HTTPURLResponse else {
            // check if response for local file
            if responseArg.urlResponse?.url?.isFileURL ?? false, let responseData = responseArg.data {
                decodeJsonData(responseData, model, completion)
            } else {
                DispatchQueue.main.async {
                    completion(nil, AHNetworkError.empty)
                }
            }
            return
        }
        
        let result = httpResponse.handleNetworkResponse()
        switch result {
        case .success:
            guard let responseData = responseArg.data else {
                DispatchQueue.main.async {
                    completion(nil, AHNetworkResponse.noData)}
                return
            }
            AHNetworkLogger.log(response: httpResponse)
            decodeJsonData(responseData, model, completion)
            var path = NSURLComponents(string: httpResponse.url?.absoluteString ?? "")?.path ?? ""
            path  = path.replacingOccurrences(of: "/", with: "_")
            do {
                try AHCachingManager.shared.write(into: path, data: responseData)
            } catch {
                print(" could not cache response")
                DispatchQueue.main.async {
                    completion(nil, AHNetworkError.empty)
                }
            }
        case let .failure(networkResponseError):
            DispatchQueue.main.async {
                completion(nil, networkResponseError)}
        }
    }
}

/// this extension for building the request and cofigure parameter and build headers
extension AHNetworkClient {

    open func buildRequest(from endPoint: AHRequestProtocol,
                           with headers: HTTPHeaders,
                           to baseURL: URL?) throws -> URLRequest {
        guard let baseURL = baseURL else {
            throw AHNetworkError.missingURL
        }
        var request = URLRequest(url: baseURL.appendingPathComponent(endPoint.path),
                                 cachePolicy: endPoint.cachePolicy,
                                 timeoutInterval: self.timeout)
        request.allHTTPHeaderFields = headers
        request.httpMethod = endPoint.httpMethod.rawValue
        do {
            switch endPoint.httpTask {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case let .requestParameters(bodyParameters,
                                        bodyEncoding,
                                        urlParameters):
                try configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            case let .requestParametersAndHeaders( bodyParameters,
                                                   bodyEncoding,
                                                   urlParameters,
                                                   additionalHeaders):
                addAdditionalHeaders(additionalHeaders, request: &request)
                try configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    open func configureParameters(bodyParameters: Parameters?,
                                  bodyEncoding: AHParameterEncoder,
                                  urlParameters: Parameters?,
                                  request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    open func buildHeaders(request: AHRequestProtocol, completion: @escaping AHNetworkCompletion) -> HTTPHeaders {
        var requestClientHeaders: HTTPHeaders = headers ?? [:]
        if  request.isAuthenticationNeededRequest ?? false {
            authClientProvider?.requestAuthToken { (token, error) in
                guard let token = token?.first else {
                    completion(nil, error)
                    return
                }
                requestClientHeaders[token.key] = token.value
            }
        }
        request.headers?.forEach {
            requestClientHeaders[$0.key] = $0.value
        }
        return requestClientHeaders
    }
}
