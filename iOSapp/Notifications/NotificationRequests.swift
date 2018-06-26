//
//  SnipLoggerRequests.swift
//  iOSapp
//
//  Created by Carl Zeiger on 6/20/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Crashlytics
import RealmSwift

class NotificationRequests {
    static let instance = NotificationRequests()
    
    let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
        do {
            var request: URLRequest = try endpoint.urlRequest()
            request.httpShouldHandleCookies = false
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    let provider: MoyaProvider<NotificationService>.CompatibleType
    let disposeBag: DisposeBag = DisposeBag()
    init() {
        self.provider = MoyaProvider<NotificationService>(requestClosure: requestClosure)
    }
    
    func sendFirebaseToken(registrationToken: String) {
        provider.rx.request(NotificationService.firebaseToken(registrationToken: registrationToken))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (response) in
                print("Successfuly sent firebase token \(registrationToken)")
            }) { (err) in
                print("Error sending firebase token \(registrationToken): \(err)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: disposeBag)
    }
    
    func subscribeToTopic(topicID: Int) {
        provider.rx.request(NotificationService.subscribe(topic: topicID))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> Bool in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("JSON", obj) }
                guard let message = json["message"] as? String else { throw SerializationError.missing("message") }
                return message == "success"
            }
            .subscribe(onSuccess: { (success) in
                if success {
                    print("Successfully subscribed to topic \(topicID)")
                } else {
                    print("Error subscribing to topic \(topicID)")
                }
            }) { (err) in
                print("Error subscribing to topic \(topicID)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: self.disposeBag)
    }
    
    func unsubscribeToTopic(topicID: Int) {
        provider.rx.request(NotificationService.unsubscribe(topic: topicID))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .mapJSON()
            .map { obj -> Bool in
                guard let json = obj as? [String: Any] else { throw SerializationError.invalid("JSON", obj) }
                guard let message = json["message"] as? String else { throw SerializationError.missing("message") }
                return message == "success"
            }
            .subscribe(onSuccess: { (success) in
                if success {
                    print("Successfully unsubscribed to topic \(topicID)")
                } else {
                    print("Error unsubscribing to topic \(topicID)")
                }
            }) { (err) in
                print("Error unsubscribing to topic \(topicID)")
                Crashlytics.sharedInstance().recordError(err)
            }
            .disposed(by: self.disposeBag)
    }
    
    func logNotificationClicked(notificationId: Int) {
        provider.rx.request(NotificationService.logNotificationClicked(notificationId: notificationId))
            .subscribeOn(MainScheduler.asyncInstance)
            .mapSnipRequest()
            .subscribe(onSuccess: { (response) in
                print("Logged notification click")
            }) { (err) in
                print("Error logging notification click \(err)")
                Crashlytics.sharedInstance().recordError(err)
        }
    }
}
