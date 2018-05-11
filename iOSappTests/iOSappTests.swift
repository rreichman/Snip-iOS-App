//
//  iOSappTests.swift
//  iOSappTests
//
//  Created by Ran Reichman on 10/19/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import XCTest
import BigInt
import RxSwift
import RxBlocking
@testable import iOSapp

class iOSappTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTokenBalance() {
        let promise = expectation(description: "token balance")
        let dis = InfuraRequests.instance.getTokenBalance(contract: "0x2b8808a54fd3c55e01d3b95b6f1a0eaab3f952cc", wallet: "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f")
            //.observeOn(MainScheduler.instance)
            
            .subscribe(onSuccess: { bal in
                XCTAssert(bal > BigInt(0))
                promise.fulfill()
            }, onError: { _ in
                XCTFail()
            })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testEthBalance() {
        let promise = expectation(description: "eth balance")
        let dis = InfuraRequests.instance.getEthBalance(wallet: "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f")
            //.observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { bal in
                XCTAssert(bal > BigInt(0))
                promise.fulfill()
            }, onError: { _ in
                XCTFail()
            })
        waitForExpectations(timeout: 8, handler: nil)
    }
    func testTransactionCount() {
        let promise = expectation(description: "transaction count")
        let dis = InfuraRequests.instance.getTransactionCount(address: "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f")
            //.observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { bal in
                print("transaction count: \(bal)")
                XCTAssert(bal > 0)
                promise.fulfill()
            }, onError: { _ in
                XCTFail()
            })
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func testGasData() {
        let promise = expectation(description: "gas price")
        let dis = GasRequests.instance.getGasData()
            .subscribe(onSuccess: { (data) in
                XCTAssert(data.priceInt(for: .low) > 0)
                XCTAssert(data.timeDouble(for: .medium) > 0)
                promise.fulfill()
            }) { err in
                print(err)
                XCTFail()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    func testSnipEthExchange() {
        let promise = expectation(description: "snip eth exchange")
        let dis = TickerRequests.instance.getSnipEthExchange()
            .subscribe(onSuccess: { (exchange) in
                XCTAssert(exchange > 0.0)
                promise.fulfill()
            }) { err in
                print(err)
                XCTFail()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    func testEthUsdExchange() {
        let promise = expectation(description: "eth usd exchange")
        let dis = TickerRequests.instance.getEthUsdExchange()
            .subscribe(onSuccess: { (exchange) in
                XCTAssert(exchange > 0.0)
                promise.fulfill()
            }) { err in
                print(err)
                XCTFail()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGenerateRaw() {
        let keystore = SnipKeystore.instance
        let gasData = RealmManager.instance.getGasData()
        do {
            let signTransaction = try keystore.makeTransaction(to: "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f", gasData: gasData, gasLimit: .eth, amount: BigInt(1), nonce: 68, data: Data())
            let raw = try keystore.signTransaction(signTransaction)
            print("raw: \(WalletUtils.dataToHexString(data: raw.0))")
            XCTAssert(raw.0.count > 0)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testSendRawTransaction() {
        let keystore = SnipKeystore.instance
        let gasData = RealmManager.instance.getGasData()
        var raw: Data = Data()
        do {
            let signTransaction = try keystore.makeTransaction(to: "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f", gasData: gasData, gasLimit: .eth,   amount: BigInt(1), nonce: 69, data: Data())
            var hash: String = ""
            (raw, hash) = try keystore.signTransaction(signTransaction)
            print("raw: \(WalletUtils.dataToHexString(data: raw))")
        } catch {
            print(error)
        }
        
        let promise = expectation(description: "transaction count")
        let dis = InfuraRequests.instance.sendRawTransaction(raw: raw)
            //.observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { (hash) in
                print("transaction hash: \(hash)")
                XCTAssert(hash != "")
                promise.fulfill()
            }, onError: { err in
                XCTFail()
                print(err)
            })
        waitForExpectations(timeout: 50, handler: nil)
    }
    
    func testCalcTransactionHash() {
        let keystore = SnipKeystore.instance
        let gasData = RealmManager.instance.getGasData()
        var raw: Data = Data()
        var hash: String = ""
        do {
            let signTransaction = try keystore.makeTransaction(to: "0x1b4f8ac6b16524360a09a5bd182cd03fb08fa38f", gasData: gasData, gasLimit: .eth,   amount: BigInt(1), nonce: 67, data: Data())
            (raw, hash) = try keystore.signTransaction(signTransaction)
            let test_hash = 
            XCTAssert(WalletUtils.dataToHexString(data: raw) == "0xf8624384ee6b2800825208941b4f8ac6b16524360a09a5bd182cd03fb08fa38f01802b9f6e9fe1645a4675495629a4733c5f164de8146eddb68bce6cadfb3cae2d7c7ca01745eb181ea5b1d4550f3ef816b083080fcdfbf2c4a15f75fa223b8580e2b137")
            XCTAssert(hash == "0x5fd31945b554009502b4109e08b2ea3119051138bde027a0abdc22e074965123")
            print("raw: \(WalletUtils.dataToHexString(data: raw))")
        } catch {
            print(error)
        }
    }
}
