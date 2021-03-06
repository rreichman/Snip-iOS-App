//
//  Network.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/2/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation

struct NetworkSettings {
    private static let main_net: NetworkSettings = NetworkSettings("https://api.etherscan.io", "0x44F588aEeB8C44471439D1270B3603c66a9262F1", 1, "mainnet")
    private static let rinkeby: NetworkSettings = NetworkSettings("https://api-rinkeby.etherscan.io", "0x2b8808a54fd3c55e01d3b95b6f1a0eaab3f952cc", 4, "rinkeby")
    static func getNetwork() -> NetworkSettings {
        #if MAIN
        return NetworkSettings.main_net
        #else
        return NetworkSettings.rinkeby
        #endif
    }
    let etherscan_url: String
    let infura_url: String = "https://api.infura.io"
    let gas_service_url: String = "https://f8v6osnp4l.execute-api.us-east-1.amazonaws.com/"
    let etherscan_api: String = "ZYZSJ92PB9JETQTT1JZ4U9K89ZYDXT2F3T"
    let infura_api_key: String = "Ha2ZDaCPOOY6q0OPbYlD"
    let contract_address: String
    let network_name: String
    let chain_id: Int
    init(_ eth: String, _ contract: String, _ chain: Int, _ name: String) {
        self.etherscan_url = eth
        self.contract_address = contract.lowercased()
        self.chain_id = chain
        self.network_name = name
    }
}
