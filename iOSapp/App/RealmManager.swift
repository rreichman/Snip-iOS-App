
import Foundation
import RealmSwift

class RealmManager {

    static var instance: RealmManager!
    
    var realm: Realm!
    var memRealm: Realm!
    init() {
        buildDiskRealm()
        buildMemoryRealm()
    }
    
    func buildDiskRealm() {
        let version: UInt64 = 23
        // Inside your application(application:didFinishLaunchingWithOptions:)
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: version,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < version) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        self.realm = try! Realm()
        print("realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    func buildMemoryRealm() {
        let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
        self.memRealm = realm
        print("memory realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    }
    
    func getRealm() -> Realm {
        return self.realm
    }
    
    func getMemRealm() -> Realm {
        return self.memRealm
    }
    
    func getGasData() -> GasData {
        let existing = getRealm().objects(GasData.self)
        if existing.count == 0 {
            // No singleton object
            let data = GasData()
            try! getRealm().write {
                getRealm().add(data)
            }
            return data
        } else {
            return existing[0]
        }
    }
    
    func getExchangeData() -> ExchangeData {
        let existing = getRealm().objects(ExchangeData.self)
        if existing.count == 0 {
            // No singleton object
            let data = ExchangeData()
            try! getRealm().write {
                getRealm().add(data)
            }
            return data
        } else {
            return existing[0]
        }
    }
}
