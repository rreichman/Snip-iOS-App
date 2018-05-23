import XCTest
import BigInt
import RxSwift
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
    
    func testGetNextPage() {
        let promise = expectation(description: "load next page")
        var params: [String: Any] = [:]
        params["category"] = "Politics"
        
        let _ = self.request.getMain()
            .flatMap { (catList) -> Single<iOSapp.Category> in
                let category = catList[1]
                return self.request.getNextPage(for: category)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { category in
                XCTAssert(category.posts.count > 1)
                promise.fulfill()
            }, onError: { err in
                print(err)
            })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testVotePost() {
        let promise = expectation(description: "load next page")
        var params: [String: Any] = [:]
        params["category"] = "Politics"
        
        let _ = self.request.getMain()
            .flatMap { (catList) -> Single<iOSapp.Category> in
                let category = catList[1]
                return self.request.getNextPage(for: category)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { category in
                XCTAssert(category.posts.count > 1)
                SnipRequests.instance.postVoteState(post: category.topThreePosts[0], vote_state: .like)
            }, onError: { err in
                print(err)
            })
        waitForExpectations(timeout: 5, handler: nil)
        let cat = RealmManager.instance.getMemRealm().object(ofType: Category.self, forPrimaryKey: "Politics")!
        print(cat.topThreePosts[0].isLiked)
    }
}
