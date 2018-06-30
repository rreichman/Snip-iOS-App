//
//  AppLinkRequests.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/28/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class AppLinkRequests {
    static var instance: AppLinkRequests = AppLinkRequests()
    
    let provider: MoyaProvider<AppLinkService>.CompatibleType
    let disposebag: DisposeBag = DisposeBag()
    
    init() {
        self.provider = MoyaProvider<AppLinkService>()
    }
    
    
    // Returns post slug if there is one, nil otherwise
    func followRedirects(urlInSnipDomain: URL) -> Single<String> {
        return provider.rx.request(AppLinkService.resolveAppLink(link: urlInSnipDomain))
            .subscribeOn(MainScheduler.asyncInstance)
            .map { response in
                //print("response url \(response.response?.url?.absoluteString) request url \(response.request?.url?.absoluteString)")
                guard let redirect_url = response.response?.url else { throw APIError.unableToResolveAppLink(of: urlInSnipDomain) }
                let action = AppLinkUtils.routeAppLink(link: redirect_url)
                switch action {
                case .openPost(let slug):
                    return slug
                default:
                    throw APIError.unableToResolveAppLink(of: urlInSnipDomain)
                }
            }
    }
}
