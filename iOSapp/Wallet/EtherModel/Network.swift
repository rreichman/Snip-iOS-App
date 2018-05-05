//
//  Network.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/2/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation

struct NetworkSettings {
    static let main_net: NetworkSettings = NetworkSettings("https://api.etherscan.io", "https://mainnet.infura.io/Ha2ZDaCPOOY6q0OPbYlD", "0x44F588aEeB8C44471439D1270B3603c66a9262F1", 1)
    static let rinkeby: NetworkSettings = NetworkSettings("https://api-rinkeby.etherscan.io", "https://rinkeby.infura.io/Ha2ZDaCPOOY6q0OPbYlD", "0x2b8808a54fd3c55e01d3b95b6f1a0eaab3f952cc", 4)
    
    let etherscan_url: String
    let infura_url: String
    let gas_service_url: String = "https://f8v6osnp4l.execute-api.us-east-1.amazonaws.com/"
    let etherscan_api: String = "ZYZSJ92PB9JETQTT1JZ4U9K89ZYDXT2F3T"
    let contract_address: String
    let chain_id: Int
    init(_ eth: String, _ infura: String, _ contract: String, _ chain: Int) {
        self.etherscan_url = eth
        self.infura_url = infura
        self.contract_address = contract
        self.chain_id = chain
    }
}
