import XCTest
import BigInt
import RxSwift
import RxBlocking
@testable import iOSapp

class FeedTests: XCTestCase {
    var request: SnipRequests!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        request = SnipRequests.instance
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMainFeed() {
        let promise = expectation(description: "load main feed")
        let dis = self.request.getMain()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (catList) in
                XCTAssert(catList.count > 1)
                promise.fulfill()
            }) { (err) in
                print(err)
                XCTFail()
        }
        waitForExpectations(timeout: 5, handler: nil)

    }
}
