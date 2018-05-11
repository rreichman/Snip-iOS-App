
import Foundation
import BigInt
import RealmSwift

@objcMembers
class ExchangeData: Object {
    dynamic var snipEth: Double = 0.0
    dynamic var ethUsd: Double = 0.0
    
    dynamic var key: String = "exchange_data"
    
    var snipUsd: Double {
        return snipEth * ethUsd
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
}
