import TencentSCFEvents
import Vapor
@testable import VaporTencentSCFRuntime
import XCTest

final class APIGatewayTests: XCTestCase {
    func testCreateAPIGatewayResponse() {
        let body = #"{"hello": "world"}"#
        let vaporResponse = Vapor.Response(
            status: .ok,
            headers: HTTPHeaders([
                ("Content-Type", "application/json"),
            ]),
            body: .init(string: body)
        )

        let response = APIGateway.Response(response: vaporResponse)

        XCTAssertEqual(response.body, body)
        XCTAssertEqual(response.headers.count, 2)
        XCTAssertEqual(response.headers["Content-Type"], "application/json")
        XCTAssertEqual(response.headers["content-length"], "\(body.count)")
    }
}
