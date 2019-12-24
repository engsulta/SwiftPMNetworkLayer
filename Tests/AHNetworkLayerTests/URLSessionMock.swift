
import Foundation
@testable import AHNetworkLayer

class URLSessionDataTask: URLSessionDataTaskProtocol {
    func suspend() {
    }
    func resume() {
    }
    func cancel() {
    }
}

class URLSessionMock: URLSessionProtocol {
    /// you may use this for testing the delegate method 
    weak var sessionDelegate: AHNetworkProgressDelegate?
    init(delegate: AHNetworkProgressDelegate? = nil) {
        self.sessionDelegate = delegate
    }
    var urlSessionDataTaskMock =  URLSessionDataTaskMock()
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        if let requestUrl = request.url {
        if let url = Bundle.unitTest.url(forResource: "AHNetworkTest", withExtension: ".json") {
            do {
                let data = try Data(contentsOf: url)
                let succesResponse = HTTPURLResponse(url: requestUrl,
                                                     statusCode: 200,
                                                     httpVersion: nil,
                                                     headerFields: nil)
                completionHandler(data, succesResponse, nil)
            } catch {
                completionHandler(nil, nil, AHNetworkResponse.noData)
            }
        } else {
            completionHandler(nil, nil, AHNetworkResponse.noData)
            }
        }
        return urlSessionDataTaskMock
    }
    func downloadTask(with url: URL,
                      completionHandler: @escaping DownloadTaskResult) -> URLSessionDownloadTaskProtocol {
        if url.absoluteString == "https://www.test.com" {
            if let url = Bundle.unitTest.url(forResource: "AHNetworkTest", withExtension: ".json") {
                completionHandler(url, nil, nil)
            }
        }
         return URLSessionDownloadTask()
    }

    func uploadTask(with request: URLRequest,
                    from data: Data,
                    completionHandler: @escaping DataTaskResult) -> URLSessionUploadTaskProtocol {
        if let requestUrl = request.url {
            if let url = Bundle.unitTest.url(forResource: "AHNetworkTest", withExtension: ".json") {
                do {
                    let data = try Data(contentsOf: url)
                    let succesResponse = HTTPURLResponse(url: requestUrl,
                                                         statusCode: 200,
                                                         httpVersion: nil,
                                                         headerFields: nil)
                    completionHandler(data, succesResponse, nil)
                } catch {
                    completionHandler(nil, nil, AHNetworkResponse.noData)
                }
            }

        }
            return URLSessionUploadTask()
        }
}
class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    var isCancelledCalled = false
    var isResumedCalled = false
    var isSuspendCalled = false

    func resume() {
        isResumedCalled = true
        isCancelledCalled = false
        isSuspendCalled = false
    }
    func suspend() {
        isSuspendCalled = true
        isCancelledCalled = false
        isResumedCalled = false
    }
    func cancel() {
        isCancelledCalled = true
        isResumedCalled = false
        isSuspendCalled = false
    }
}
