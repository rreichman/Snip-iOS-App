//
//  CategoryParams.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class CategoryParam: Object {
    dynamic var param: String = ""
    dynamic var value: String = ""
    
}

extension CategoryParam {
    static func parseJson(param: String, value: String) throws -> CategoryParam {
        let catParam = CategoryParam()
        catParam.param = param
        catParam.value = value
        return catParam
    }
}
