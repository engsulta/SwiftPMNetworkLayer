
import XCTest
@testable import AHNetworkLayer

class AHRequestProtocolTests: XCTestCase {

    class MockRequest: AHRequestProtocol {
        var cache: Bool?
        
        var path: String
        var baseUrl: String
        var httpMethod: HTTPMethod
        var headers: [String: String]?
        var httpTask: HTTPTask

        var isAuthenticationNeededRequest: Bool?
        var cachePolicy: CachePolicy

        init(path: String ,
             baseUrl: String,
             httpTask: HTTPTask = .request,
             httpMethod: HTTPMethod = .get,
             headers: [String: String]? = nil) {

            self.baseUrl = baseUrl
            self.path = path
            self.httpMethod = httpMethod
            self.headers = headers
            self.httpTask = httpTask

            self.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            self.isAuthenticationNeededRequest = true
        }
    }

    let session = URLSessionMock()
    var mockClient: AHNetworkClient!
    var mockNormalRequest: AHRequestProtocol!
    let testParmaters = ["name": "atta"]

    override func setUp() {
        super.setUp()
        mockClient = AHNetworkClient(baseURL: "www.test.com", session: session)
        mockNormalRequest = AHRequest(path: "www.test.com", httpMethod: .get,
                                       httpTask: .request,
                                       headers: ["test": "test"],
                                       isAuthenticationNeededRequest: false,
                                       cachePolicy: .reloadIgnoringLocalCacheData)
    }

    override func tearDown() {
        mockClient = nil
        mockNormalRequest = nil
        super.tearDown()
    }

    func testRequestWithoutParams() {
        let mockRequest: MockRequest = MockRequest(path: "/demo", baseUrl: "www.test2.com", httpTask: .request)
        excute(request: mockRequest)
    }

    func testRequestWithBodyParamters() {
        let mockRequest: MockRequest = MockRequest(path: "/demo",
                                                   baseUrl: "www.test2.com",
                                                   httpTask: .requestParameters(
                                                    bodyParameters: testParmaters,
                                                    bodyEncoding: .urlEncoding,
                                                    urlParameters: testParmaters),
                                                   headers: testParmaters)
        excute(request: mockRequest)
    }

    func testRequestWithJsonEncode() {
        let mockRequest: MockRequest = MockRequest(path: "/demo",
                                                   baseUrl: "www.test2.com",
                                                   httpTask: .requestParameters(
                                                    bodyParameters: testParmaters,
                                                    bodyEncoding: .jsonEncoding,
                                                    urlParameters: testParmaters),
                                                   headers: testParmaters)
        excute(request: mockRequest)
    }

    func testRequestWithUrlAndJsonEncoding() {
        let mockRequest: MockRequest = MockRequest(path: "/demo",
                                                   baseUrl: "www.test2.com",
                                                   httpTask: .requestParameters(
                                                    bodyParameters: testParmaters,
                                                    bodyEncoding: .urlAndJsonEncoding,
                                                    urlParameters: testParmaters),
                                                   headers: testParmaters)
        excute(request: mockRequest)
    }
    func testRequestWithAdditionalHeader() {
        let mockRequest: MockRequest = MockRequest(path: "/demo",
                                                   baseUrl: "www.test2.com",
                                                   httpTask: .requestParametersAndHeaders(
                                                    bodyParameters: testParmaters,
                                                    bodyEncoding: .bodyDataEncoding,
                                                    urlParameters: testParmaters,
                                                    extraHeaders: testParmaters),
                                                   headers: testParmaters)
        excute(request: mockRequest)
    }

    fileprivate func excute(request: MockRequest) {
        let exp = expectation(description: #function)
        mockClient.execute(request: request, model: MockModel.self) { (model, error) in
            if error != nil {
                XCTAssertNotNil(error as? AHNetworkResponse)
            } else {
                 XCTAssertNotNil(model)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }

//    func testDecodingSuccess() {
//        let exp = expectation(description: #function)
//        mockClient.execute(request: mockNormalRequest, model: [String].self) { model, error in
//            if error != nil {
//                XCTFail(error.debugDescription)
//            } else {
//                XCTAssertNotNil(model)
//            }
//             exp.fulfill()
//        }
//        wait(for: [exp], timeout: 2.0)
//    }
    func testDecodingFailure() {
        let exp = expectation(description: #function)
        mockClient.execute(request: mockNormalRequest, model: Int.self) { _, error in
            if error != nil {
               XCTAssertTrue(true)
            } else {
                XCTFail("decoding not work successfully")
            }
            exp.fulfill()
        }
         wait(for: [exp], timeout: 2.0)
    }
    func testCancellingTask() {
        let exp = expectation(description: #function)
        mockClient.execute(request: mockNormalRequest, model: [String].self) { _, _ in
        }
        mockClient.cancel(request: mockNormalRequest) {
            XCTAssertTrue(self.session.urlSessionDataTaskMock.isCancelledCalled)
             exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
// internal hash for network foundation so that it can cancel your request
    func testHashingRequests() {
        mockNormalRequest = AHRequest(path: "www.test.com", httpMethod: .get,
                                       httpTask: .requestParameters(bodyParameters:["key1": "val1"],
                                                                    bodyEncoding: .urlEncoding,
                                                                    urlParameters: ["key2": "val2"]),
                                       headers: ["test": "test"],
                                       isAuthenticationNeededRequest: false,
                                       cachePolicy: .reloadIgnoringLocalCacheData)
    let hash1 = mockNormalRequest.hash
        mockNormalRequest = AHRequest(path: "www.test.com", httpMethod: .get,
                                       httpTask: .requestParameters(bodyParameters:["key1": "val1"],
                                                                    bodyEncoding: .urlEncoding,
                                                                    urlParameters: ["key2": "v2"]),
                                       headers: ["test": "test"],
                                       isAuthenticationNeededRequest: false,
                                       cachePolicy: .reloadIgnoringLocalCacheData)
        let hash2 = mockNormalRequest.hash
        XCTAssert(hash1 != hash2)
    }
//    func testLocalizationSuccess() {
//        guard let url = Bundle.unitTest.url(forResource: "AHNetworkTest", withExtension: "json") else {
//            XCTFail("Unable to read AHNetworkTest.json")
//            return
//        }
//        let expec = expectation(description: "data")
//        let request = AHRequest(isAuthenticationNeededRequest: false)
//        let networkClient = AHNetworkClient(baseURL: url.absoluteString, session: URLSession.shared)
//        networkClient.execute(request: request, model: [String: String].self) { (fetchedModel, _ ) in
//            guard let model = fetchedModel as? [String: String] else {
//                return
//            }
//            expec.fulfill()
//            XCTAssertEqual(model["trayItems"], "Any value")
//        }
//        wait(for: [expec], timeout: 2)
//    }

//    func testDownloadFile() {
//        let exp = expectation(description: #function)
//        mockClient = AHNetworkClient(baseURL: "", session: session)
//        mockClient.download(url: "https://www.test.com", progressClosure: nil) { location, _, _ in
//            exp.fulfill()
//            XCTAssertNotNil(location)
//        }
//        wait(for: [exp], timeout: 10.0)
//    }
//
//    func testUploadFile() {
//        let exp = expectation(description: #function)
//        mockClient = AHNetworkClient(baseURL: "https://www.test.com", session: session)
//        let request = AHRequest(httpMethod: .post, isAuthenticationNeededRequest: false)
//        mockClient.upload(request: request, responseModel: [String].self, uploadModel: MockModel()) { model, _ in
//            exp.fulfill()
//            XCTAssertNotNil(model)
//        }
//        wait(for: [exp], timeout: 10.0)
//    }
}
struct MockModel: Codable {
}
