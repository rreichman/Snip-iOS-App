//
//  Single+Extension.swift
//  iOSapp
//
//  Created by CJ Zeiger on 5/4/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift

extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    public func mapServerErrors() -> Single<Response> {
        return map { response -> Response in
            if response.statusCode >= 500 {
                throw APIError.serverError(errorMessage: response.description, code: response.statusCode)
            } else if response.statusCode >= 400 {
                throw APIError.requestError(errorMessage: response.description, code: response.statusCode)
            }
            return response
        }
    }
}
