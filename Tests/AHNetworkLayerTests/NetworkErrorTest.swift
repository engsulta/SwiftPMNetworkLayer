
import XCTest
@testable import AHNetworkLayer
class AHNetworkErrorTest: XCTestCase {
    func testNetworkErrorLocalizedDescription() {
        let expected: [String] = ["Unable to parse response",
                                  "Network operation failed",
                                  "Empty response",
                                  "missing URL",
                                  "encodingFailed",
                                  "Unknown",
                                  "Authentication token missed",
                                  "no Internet Connection"]

        for (index, testError) in [AHNetworkError.parse,
                                   AHNetworkError.network,
                                   AHNetworkError.empty,
                                   AHNetworkError.missingURL,
                                   AHNetworkError.encodingFailed,
                                   AHNetworkError.unknown,
                                   AHNetworkError.authFailed,
                                   AHNetworkError.noInternetConnection].enumerated() {
                                    XCTAssertEqual(testError.rawValue, expected[index])
        }
    }

    func testNetworkResponseErrorLocalizedDescription() {
        let expected: [String] = ["You need to be authenticated first.",
                                  "Bad request",
                                  "server encountered an unexpected condition",
                                  "The url you requested is outdated.",
                                  "Network request failed.",
                                  "Response returned with no data to decode.",
                                  "We could not decode the response."]
        for (index, testError) in [AHNetworkResponse.authenticationError,
                                   AHNetworkResponse.badRequest,
                                   AHNetworkResponse.serverError,
                                   AHNetworkResponse.outdated,
                                   AHNetworkResponse.failed,
                                   AHNetworkResponse.noData,
                                   AHNetworkResponse.unableToDecode].enumerated() {
                                    XCTAssertEqual(testError.rawValue, expected[index])
        }
    }
}
