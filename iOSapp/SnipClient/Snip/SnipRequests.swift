//
//  SnipRequests.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/16/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Crashlytics

class SnipRequests {
    static let instance = SnipRequests()
    
    let provider: MoyaProvider<SnipService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    init() {
        self.provider = MoyaProvider<SnipService>()
    }
    
    func getMain() -> Single<[Category]> {
        return provider.rx.request(SnipService.main)
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapServerErrors()
            .mapJSON()
            .map { [weak self] obj -> [Category] in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("invalid json response", obj) }
                guard let jsonList = json["posts_data"] as? [ [String: Any] ] else { throw SerializationError.missing("posts_data") }
                let categories = try Category.parseJsonList(json: jsonList)
                guard let sr = self else {
                    return categories
                }
                for cat in categories {
                    for post in cat.posts {
                        if let image = post.image {
                            let _ = sr.getPostImage(image: image)
                            .subscribe()
                        }
                    }
                }
                return categories
        }
    }
    
    func getPostImage(image: Image) -> Single<Bool> {
        return provider.rx.request(SnipService.getPostImage(imageURL: image.imageUrl))
            .subscribeOn(SingleBackgroundThread.scheduler)
            .mapServerErrors()
            .map { response -> Data in
                return response.data
            }
            .observeOn(MainScheduler.instance)
            .map { data -> Bool in
                try! image.realm?.write {
                    image.data = data
                }
                return true
            }
            .catchError({ (err) -> Single<Bool> in
                Crashlytics.sharedInstance().recordError(err, withAdditionalUserInfo: ["imageURL": image.imageUrl ])
                print("Error loading \(image.imageUrl) \(err)")
                return Single.just(false)
            })
    }
}
