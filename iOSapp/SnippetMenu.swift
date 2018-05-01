//
//  SnippetMenu.swift
//  iOSapp
//
//  Created by Ran Reichman on 2/26/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import UIKit

extension SnippetView {
    func sendReportToServer(snippetID: Int, reasons: String)
    {
        let reportInfo : ReportInfo = ReportInfo(snippetID: snippetID, reasons: reasons)
        testSendReportToServer(reportParams: reportInfo)
    }

    func getServerStringForReport() -> String
    {
        var urlString : String = SystemVariables().URL_STRING
        urlString.append("report_post/")
        
        return urlString
    }

    func testSendReportToServer(reportParams : Any)
    {
        let convertedReportParams : ReportInfo = reportParams as! ReportInfo
        
        let serverString = getServerStringForReport()
        var urlRequest = getDefaultURLRequest(serverString: serverString, method: "POST")
        
        let jsonString = convertDictionaryToJsonString(dictionary: convertedReportParams.getDataAsDictionary())
        urlRequest.httpBody = jsonString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in            
            guard let _ = data, error == nil else
            {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }

    func handleSpamReport(alertAction: UIAlertAction)
    {
        sendReportToServer(snippetID: currentSnippetId, reasons: "spam")
        print("this is spam")
    }

    func handleContentNotOriginalReport(alertAction: UIAlertAction)
    {
        sendReportToServer(snippetID: currentSnippetId, reasons: "contentnotoriginal")
        print("content not original")
    }

    func handlePhotoNotOriginalReport(alertAction: UIAlertAction)
    {
        sendReportToServer(snippetID: currentSnippetId, reasons: "photonotoriginal")
        print("photo not original")
    }

    func handleHarmfulOrOffendingReport(alertAction: UIAlertAction)
    {
        sendReportToServer(snippetID: currentSnippetId, reasons: "harmfuloroffending")
        print("harmful or offending")
    }
    
    func handleUnwantedAdvertising(alertAction: UIAlertAction)
    {
        sendReportToServer(snippetID: currentSnippetId, reasons: "unwantedadvertising")
        print("harmful or offending")
    }

    func handleIdontLikeThisReport(alertAction: UIAlertAction)
    {
        sendReportToServer(snippetID: currentSnippetId, reasons: "idontlikethis")
        print("I don't like this")
    }

    func handleSnippetMenuButtonClicked(snippetID : Int, viewController : UIViewController)
    {
        print("test button")
        let alertController = UIAlertController()
        
        let spamAction = UIAlertAction(title: "Report Spam", style: .default, handler: handleSpamReport)
        let notOriginalContentAction = UIAlertAction(title: "Content Isn't Original", style: .default, handler: handleContentNotOriginalReport)
        let notOriginalPhotoAction = UIAlertAction(title: "Photo Isn't Original", style: .default, handler: handlePhotoNotOriginalReport)
        let harmfulOrOffendingAction = UIAlertAction(title: "Post is Harmful or Offending", style: .default, handler: handleHarmfulOrOffendingReport)
        let unwantedAdvertisingAction = UIAlertAction(title: "Post is Unwanted Advertising", style: .default, handler: handleUnwantedAdvertising)
        let dontLikeThisAction = UIAlertAction(title: "I Don't Like This", style: .default, handler: handleIdontLikeThisReport)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(spamAction)
        alertController.addAction(notOriginalContentAction)
        alertController.addAction(notOriginalPhotoAction)
        alertController.addAction(harmfulOrOffendingAction)
        alertController.addAction(unwantedAdvertisingAction)
        alertController.addAction(dontLikeThisAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = shareView
        
        viewController.present(alertController, animated: true)
    }
}
