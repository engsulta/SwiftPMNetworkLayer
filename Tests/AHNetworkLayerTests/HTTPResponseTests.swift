
import Foundation
import XCTest
@testable import AHNetworkLayer

class HTTPResponseTests: XCTestCase {

    func testHandleNetworkResponseSuccessed() {
        guard let url = URL(string: "www.test.com") else {
            XCTFail("fail to create url")
            return
        }
        guard let succesResponse = HTTPURLResponse(url: url,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil) else {
                                                    XCTFail("fail to create response")
                                                    return
        }
        let result = succesResponse.handleNetworkResponse()
        switch result {
        case .success:
            XCTAssert(true)
            XCTAssertLessThanOrEqual(succesResponse.statusCode, 299)
        case .failure:
            XCTAssert(false)
        }
    }

    func testHandleNetworkResponseFailuer() {
        guard let url = URL(string: "www.test.com") else {
            XCTFail("fail to create url")
            return
        }
        guard let failResponse = HTTPURLResponse(url: url,
                                                   statusCode: 401,
                                                   httpVersion: nil,
                                                   headerFields: nil) else {
                                                    XCTFail("fail to create response")
                                                    return
        }
        let result = failResponse.handleNetworkResponse()
        switch result {
        case .success:
            XCTAssert(false)
        case .failure:
            XCTAssertLessThanOrEqual(failResponse.statusCode, 500)
            XCTAssert(true)
        }
    }
}
